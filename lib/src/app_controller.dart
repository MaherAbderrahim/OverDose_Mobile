import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'models.dart';
import 'services/api_client.dart';
import 'services/auth_store.dart';

class AppController extends ChangeNotifier {
  AppController({ApiClient? apiClient, AuthStore? authStore})
    : _apiClient = apiClient ?? ApiClient(),
      _authStore = authStore ?? AuthStore();

  final ApiClient _apiClient;
  final AuthStore _authStore;

  bool isBootstrapping = true;
  bool isBusy = false;
  String? errorMessage;
  String? token;
  AppUser? currentUser;
  List<AllergyItem> allergies = const [];
  List<int> selectedAllergyIds = const [];
  List<ProductItem> products = const [];

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  Future<void> bootstrap() async {
    isBootstrapping = true;
    notifyListeners();

    try {
      token = await _authStore.readToken();
      if (token != null) {
        await refreshSession();
      }
    } catch (error) {
      errorMessage = error.toString();
      await logout(quiet: true);
    } finally {
      isBootstrapping = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    await _runBusy(() async {
      final session = await _apiClient.login(email: email, password: password);
      token = session.token;
      currentUser = session.user;
      await _authStore.writeToken(session.token);
      await _loadProfileExtras();
      await refreshProducts(silent: true);
    });
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String gender,
    DateTime? dateOfBirth,
  }) async {
    await _runBusy(() async {
      final session = await _apiClient.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      token = session.token;
      currentUser = session.user;
      await _authStore.writeToken(session.token);
      await _loadProfileExtras();
      await refreshProducts(silent: true);
    });
  }

  Future<void> refreshSession() async {
    if (!isAuthenticated) return;
    await _runBusy(() async {
      currentUser = await _apiClient.fetchProfile(token!);
      await _loadProfileExtras();
      await refreshProducts(silent: true);
    });
  }

  Future<void> saveProfile(AppUser updatedUser) async {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    await _runBusy(() async {
      currentUser = await _apiClient.updateProfile(
        token: token!,
        user: updatedUser,
      );
      await _loadProfileExtras();
    });
  }

  Future<void> saveProfilePreferences({
    required AppUser updatedUser,
    required List<int> allergyIds,
  }) async {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    await _runBusy(() async {
      currentUser = await _apiClient.updateProfile(
        token: token!,
        user: updatedUser,
      );
      await _apiClient.updateCurrentUserAllergies(
        token: token!,
        allergyIds: allergyIds,
      );
      await _loadProfileExtras();
    });
  }

  Future<AllergyItem> createAllergy(String name) async {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    return _runBusyResult(() async {
      final allergy = await _apiClient.createAllergy(token: token!, name: name);
      allergies = [...allergies, allergy]
        ..sort(
          (left, right) =>
              left.name.toLowerCase().compareTo(right.name.toLowerCase()),
        );
      notifyListeners();
      return allergy;
    });
  }

  Future<void> refreshProducts({bool silent = false}) async {
    if (!isAuthenticated) {
      products = const [];
      notifyListeners();
      return;
    }
    if (!silent) {
      isBusy = true;
      notifyListeners();
    }
    try {
      products = await _apiClient.fetchProducts(token!);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      if (!silent) {
        isBusy = false;
        notifyListeners();
      }
    }
  }

  Future<void> createProduct({
    required String name,
    required String brand,
    required ProductCategory category,
    required List<String> ingredients,
    required String barcode,
    required String extractionMethod,
  }) async {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    await _runBusy(() async {
      await _apiClient.createProduct(
        token: token!,
        name: name,
        brand: brand,
        category: category,
        ingredients: ingredients,
        barcode: barcode,
        extractionMethod: extractionMethod,
      );
      await refreshProducts(silent: true);
    });
  }

  Future<ProductItem> saveAnalyzedProduct(Map<String, dynamic> source) async {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    return _runBusyResult(() async {
      final product = await _apiClient.saveAnalyzedProduct(
        token: token!,
        source: source,
      );
      await refreshProducts(silent: true);
      return product;
    });
  }

  /// Segmentation — accepte un [XFile] (compatible Web et mobile).
  Future<SegmentationBatch> segmentImage(XFile imageFile) async {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    return _apiClient.segmentImage(token: token!, image: imageFile);
  }

  Future<List<AnalyzedProduct>> analyzeSelected({
    required String sessionId,
    required List<String> productIds,
  }) {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    return _apiClient.analyzeSelected(
      token: token!,
      sessionId: sessionId,
      productIds: productIds,
    );
  }

  /// Scan rapide — accepte un [XFile] (compatible Web et mobile).
  Future<QuickScanResponse> quickScanImage(XFile imageFile) {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    return _apiClient.quickScanImage(token: token!, image: imageFile);
  }

  Future<void> refreshAllergies() async {
    if (!isAuthenticated) return;
    await _runBusy(() async {
      await _loadProfileExtras();
    });
  }

  Future<void> logout({bool quiet = false}) async {
    token = null;
    currentUser = null;
    products = const [];
    await _authStore.clear();
    if (!quiet) notifyListeners();
  }

  Map<ProductCategory, List<ProductItem>> groupedProducts() {
    final grouped = <ProductCategory, List<ProductItem>>{
      ProductCategory.food: [],
      ProductCategory.cosmetic: [],
      ProductCategory.unknown: [],
    };
    for (final product in products) {
      grouped[product.category]!.add(product);
    }
    return grouped;
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on ApiException catch (error) {
      errorMessage = error.message;
      rethrow;
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<T> _runBusyResult<T>(Future<T> Function() action) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      return await action();
    } on ApiException catch (error) {
      errorMessage = error.message;
      rethrow;
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> _loadProfileExtras() async {
    if (!isAuthenticated) return;
    final fetchedAllergies = await _apiClient.fetchAllergies(token!);
    final fetchedSelectedIds = await _apiClient.fetchCurrentUserAllergyIds(
      token!,
    );
    allergies = fetchedAllergies;
    selectedAllergyIds = fetchedSelectedIds;
  }
}
