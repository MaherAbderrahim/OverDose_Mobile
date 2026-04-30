import 'package:flutter/foundation.dart';

enum ProductCategory { food, cosmetic, unknown }

extension ProductCategoryX on ProductCategory {
  String get label => switch (this) {
    ProductCategory.food => 'Alimentaire',
    ProductCategory.cosmetic => 'Cosmétique',
    ProductCategory.unknown => 'Autre',
  };

  static ProductCategory fromApi(String? value) {
    final normalized = (value ?? '').toLowerCase();
    return switch (normalized) {
      'food' => ProductCategory.food,
      'cosmetic' => ProductCategory.cosmetic,
      _ => ProductCategory.unknown,
    };
  }
}

@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final DateTime? dateOfBirth;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName {
    final combined = [
      firstName,
      lastName,
    ].where((value) => value.trim().isNotEmpty).join(' ').trim();
    return combined.isEmpty ? email : combined;
  }

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
  }) {
    return AppUser(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      firstName: (json['first_name'] ?? '') as String,
      lastName: (json['last_name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      gender: (json['gender'] ?? '') as String,
      dateOfBirth: _tryParseDate(json['date_of_birth']?.toString()),
      createdAt: _tryParseDate(json['created_at']?.toString()),
      updatedAt: _tryParseDate(json['updated_at']?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'gender': gender,
    'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
  };
}

@immutable
class ProductItem {
  const ProductItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.ingredients,
    required this.barcode,
    required this.extractionMethod,
  });

  final int id;
  final String name;
  final String brand;
  final ProductCategory category;
  final List<String> ingredients;
  final String barcode;
  final String extractionMethod;

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      brand: (json['brand'] ?? '') as String,
      category: ProductCategoryX.fromApi(json['category']?.toString()),
      ingredients: (json['ingredients'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      barcode: (json['barcode'] ?? '') as String,
      extractionMethod: (json['extraction_method'] ?? '') as String,
    );
  }
}

@immutable
class BBox {
  const BBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final int x;
  final int y;
  final int width;
  final int height;

  factory BBox.fromJson(Map<String, dynamic> json) {
    return BBox(
      x: (json['x'] ?? 0) as int,
      y: (json['y'] ?? 0) as int,
      width: (json['width'] ?? 0) as int,
      height: (json['height'] ?? 0) as int,
    );
  }
}

@immutable
class SegmentedProduct {
  const SegmentedProduct({
    required this.productId,
    required this.label,
    required this.confidence,
    required this.bbox,
    required this.cropUrl,
  });

  final String productId;
  final String label;
  final double confidence;
  final BBox bbox;
  final String cropUrl;

  factory SegmentedProduct.fromJson(Map<String, dynamic> json) {
    return SegmentedProduct(
      productId: (json['product_id'] ?? '') as String,
      label: (json['label'] ?? '') as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      bbox: BBox.fromJson(Map<String, dynamic>.from(json['bbox'] as Map)),
      cropUrl: (json['crop_url'] ?? '') as String,
    );
  }
}

@immutable
class SegmentationBatch {
  const SegmentationBatch({
    required this.sessionId,
    required this.products,
    required this.totalProducts,
    required this.segmentationMode,
  });

  final String sessionId;
  final List<SegmentedProduct> products;
  final int totalProducts;
  final String segmentationMode;

  factory SegmentationBatch.fromJson(Map<String, dynamic> json) {
    return SegmentationBatch(
      sessionId: (json['session_id'] ?? '') as String,
      segmentationMode: (json['segmentation_mode'] ?? 'auto') as String,
      totalProducts: (json['total_products'] ?? 0) as int,
      products: (json['products'] as List<dynamic>? ?? const [])
          .map(
            (item) => SegmentedProduct.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

@immutable
class AnalyzedProduct {
  const AnalyzedProduct({
    required this.productId,
    required this.name,
    required this.brand,
    required this.category,
    required this.ingredients,
  });

  final String productId;
  final String name;
  final String brand;
  final String category;
  final List<String> ingredients;

  factory AnalyzedProduct.fromJson(Map<String, dynamic> json) {
    return AnalyzedProduct(
      productId: (json['product_id'] ?? '') as String,
      name: (json['name'] ?? json['label'] ?? 'Produit') as String,
      brand: (json['brand'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      ingredients: (json['ingredients'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

@immutable
class QuickScanResponse {
  const QuickScanResponse({required this.scanId, required this.ingredients});

  final int scanId;
  final List<String> ingredients;

  factory QuickScanResponse.fromJson(Map<String, dynamic> json) {
    return QuickScanResponse(
      scanId: (json['scan_id'] ?? 0) as int,
      ingredients: (json['ingredients'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

DateTime? _tryParseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
}
