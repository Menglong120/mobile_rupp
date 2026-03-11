import 'dart:convert';

import 'package:customer_order_app/core/utils/app_constant.dart';

List<ProductModel> productModelFromJson(String str) => List<ProductModel>.from(
    json.decode(str).map((x) => ProductModel.fromJson(x)));

String productModelToJson(List<ProductModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductModel {
  int id;
  int cid;
  String name;
  String description;
  String price;
  int stock;
  String image;
  String createdAt;
  String updatedAt;
  String category;
  int categoryId;

  ProductModel({
    required this.id,
    required this.cid,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    this.category = 'Other',
    this.categoryId = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: int.tryParse(json["id"]?.toString() ?? json["pid"]?.toString() ?? '0') ?? 0,
        cid: int.tryParse(json['cid']?.toString() ?? '0') ?? 0,
        name: json["name"] ?? '',
        description: json["description"] ?? '',
        price: json["price"]?.toString() ?? '0',
        stock: int.tryParse(json["stock"]?.toString() ?? '0') ?? 0,
        image: json["image"] ?? '',
        createdAt: json["created_at"] ?? '',
        updatedAt: json["updated_at"] ?? '',
        category: json["category"] is Map
            ? (json["category"]["name"] ?? 'Other')
            : (json["category"] ?? 'Other'),
        categoryId: json["category"] is Map
            ? (int.tryParse(json["category"]["id"]?.toString() ?? '0') ?? 0)
            : (int.tryParse(json["categoryId"]?.toString() ?? '0') ?? 0),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "stock": stock,
        "image": image,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "category": category,
        "categoryId": categoryId,
      };

  String getImageUrl() {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) {
      final uri = Uri.tryParse(image);
      if (uri != null && (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
        final cleanPath = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
        final query = uri.hasQuery ? '?${uri.query}' : '';
        return '$serverBaseUrl/$cleanPath$query';
      }
      return image;
    }

    // Remove any leading or trailing whitespace and leading slashes
    String cleanPath = image.trim();
    while (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    // Now cleanPath is like "products/image.png" or "api/products/8/image"
    
    // Case 1: Already an API route (e.g. from ProductApiController@formatProductResponse)
    if (cleanPath.startsWith('api/')) {
      return '$serverBaseUrl/$cleanPath';
    }

    // Case 2: For any other local path (e.g. products/nike.png), 
    // we use the API route. This ensures consistent CORS support on Web
    // and correctly resolves the path through the backend.
    if (id != 0) {
      return '$serverBaseUrl/api/products/$id/image';
    }

    // Final fallback: if no ID, try prepending storage/
    return '$serverBaseUrl/storage/$cleanPath';
  }
}
