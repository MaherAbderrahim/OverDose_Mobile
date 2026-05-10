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
  Map<String, int> productCounts = const {};
  CumulativeSummary? cumulativeSummary;
  List<Map<String, dynamic>> lastScanPayload = const [];
  bool onboardingCompleted = false;
  bool hasSkippedOnboarding = false; // Fix skip returning to onboarding

  bool get isAuthenticated => token != null && token!.isNotEmpty;
  bool get needsOnboarding =>
      isAuthenticated &&
      !onboardingCompleted &&
      ((currentUser?.userType.trim().isEmpty ?? true) ||
          selectedAllergyIds.isEmpty);

  List<ProductItem> get highRiskProducts =>
      products.where((item) => item.isHighRisk).toList();

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
      await refreshCumulativeSummary(silent: true);
      _syncOnboardingState();
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
      await refreshCumulativeSummary(silent: true);
      onboardingCompleted = false;
      _syncOnboardingState();
    });
  }

  Future<void> refreshSession() async {
    if (!isAuthenticated) return;
    await _runBusy(() async {
      currentUser = await _apiClient.fetchProfile(token!);
      await _loadProfileExtras();
      await refreshProducts(silent: true);
      await refreshCumulativeSummary(silent: true);
      _syncOnboardingState();
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
      // FRONTEND ONLY - local state update
      currentUser = updatedUser;
      selectedAllergyIds = allergyIds;
      _syncOnboardingState(forceComplete: updatedUser.userType.trim().isNotEmpty);

      /* LATER: Reconnect to backend
      currentUser = await _apiClient.updateProfile(
        token: token!,
        user: updatedUser,
      );
      await _apiClient.updateCurrentUserAllergies(
        token: token!,
        allergyIds: allergyIds,
      );
      await _loadProfileExtras();
      _syncOnboardingState(forceComplete: updatedUser.userType.trim().isNotEmpty);
      */
    });
  }

  Future<void> completeOnboarding({
    required String userType,
    required List<int> allergyIds,
  }) async {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    await _runBusy(() async {
      // FRONTEND ONLY - local state update
      if (currentUser != null) {
        currentUser = currentUser!.copyWith(userType: userType);
      }
      selectedAllergyIds = allergyIds;
      onboardingCompleted = true;

      /* LATER: Reconnect to backend
      currentUser = await _apiClient.updateUserType(
        token: token!,
        userType: userType,
      );
      await _apiClient.updateCurrentUserAllergies(
        token: token!,
        allergyIds: allergyIds,
      );
      await _loadProfileExtras();
      onboardingCompleted = true;
      */
    });
  }

  Future<AllergyItem> createAllergy(String name) async {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    return _runBusyResult(() async {
      // FRONTEND ONLY
      final newId = allergies.isNotEmpty ? allergies.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1 : 1;
      final allergy = AllergyItem(id: newId, name: name);
      allergies = [...allergies, allergy]
        ..sort(
          (left, right) =>
              left.name.toLowerCase().compareTo(right.name.toLowerCase()),
        );
      notifyListeners();
      return allergy;

      /* LATER: Reconnect to backend
      final allergy = await _apiClient.createAllergy(token: token!, name: name);
      allergies = [...allergies, allergy]
        ..sort(
          (left, right) =>
              left.name.toLowerCase().compareTo(right.name.toLowerCase()),
        );
      notifyListeners();
      return allergy;
      */
    });
  }

  Future<void> refreshProducts({bool silent = false}) async {
    if (!isAuthenticated) {
      products = const [];
      productCounts = const {};
      cumulativeSummary = null;
      notifyListeners();
      return;
    }
    if (!silent) {
      isBusy = true;
      notifyListeners();
    }
    try {
      final response = await _apiClient.fetchMyProducts(token!);
      products = response.products;
      productCounts = response.counts;
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

  Future<void> refreshCumulativeSummary({bool silent = false}) async {
    if (!isAuthenticated) {
      cumulativeSummary = null;
      if (!silent) notifyListeners();
      return;
    }

    if (!silent) {
      isBusy = true;
      notifyListeners();
    }
    try {
      cumulativeSummary = await _apiClient.fetchCumulativeSummary(token!);
      errorMessage = null;
    } on ApiException catch (error) {
      // 404 is a valid empty-state for early users with insufficient products.
      if (error.statusCode == 404) {
        cumulativeSummary = null;
        errorMessage = null;
      } else {
        errorMessage = error.message;
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      if (!silent) {
        isBusy = false;
        notifyListeners();
      }
    }
  }

  Future<void> setProductDecision({
    required int productId,
    required String decision,
    String notes = '',
  }) async {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    await _runBusy(() async {
      await _apiClient.patchProductDecision(
        token: token!,
        productId: productId,
        decision: decision,
        notes: notes,
      );
      await refreshProducts(silent: true);
      await refreshCumulativeSummary(silent: true);
    });
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

  Future<SearchAlternativesResponse> searchAlternatives(ProductItem product) {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    return _runBusyResult(() {
      return _apiClient.searchAlternatives(
        token: token!,
        productName: product.name,
        productType: product.category.recommendationType,
      );
    });
  }

  /// Segmentation — accepte un [XFile] (compatible Web et mobile).
  Future<SegmentationBatch> segmentImage(XFile imageFile) async {
    if (!isAuthenticated) throw StateError('User is not authenticated');
    return _apiClient.segmentImage(token: token!, image: imageFile);
  }

  Future<List<Map<String, dynamic>>> analyzeSelected({
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

  void setLastScanPayload(List<Map<String, dynamic>> payload) {
    lastScanPayload = payload;
    notifyListeners();
  }

  void clearLastScanPayload() {
    lastScanPayload = const [];
    notifyListeners();
  }

  void skipOnboarding() {
    onboardingCompleted = true;
    hasSkippedOnboarding = true;
    notifyListeners();
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
    productCounts = const {};
    cumulativeSummary = null;
    lastScanPayload = const [];
    onboardingCompleted = false;
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
    
    // Predefined allergies local initialization
    if (allergies.isEmpty) {
      allergies = const [
        AllergyItem(id: 1, name: 'Lactose'),
        AllergyItem(id: 2, name: 'Gluten'),
        AllergyItem(id: 3, name: 'Arachides'),
        AllergyItem(id: 4, name: 'Fruits de mer'),
        AllergyItem(id: 5, name: 'Diabète'),
        AllergyItem(id: 6, name: 'Hypertension'),
        AllergyItem(id: 7, name: 'Cholestérol'),
      ];
    }
    
    // Front-end only: do not fetch from backend so we don't overwrite local additions
    /*
    final fetchedAllergies = await _apiClient.fetchAllergies(token!);
    final fetchedSelectedIds = await _apiClient.fetchCurrentUserAllergyIds(
      token!,
    );
    allergies = fetchedAllergies;
    selectedAllergyIds = fetchedSelectedIds;
    */
  }

  void _syncOnboardingState({bool forceComplete = false}) {
    if (forceComplete || hasSkippedOnboarding) {
      onboardingCompleted = true;
      return;
    }
    final hasUserType = currentUser?.userType.trim().isNotEmpty ?? false;
    onboardingCompleted = hasUserType && selectedAllergyIds.isNotEmpty;
  }
}
