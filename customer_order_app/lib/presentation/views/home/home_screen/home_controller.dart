import 'dart:convert';

import 'package:customer_order_app/data/models/product_model.dart';
import 'package:customer_order_app/data/services/product_service.dart';
import 'package:customer_order_app/presentation/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var wishlist = <ProductModel>[].obs;

  var products = <ProductModel>[].obs;
  var filteredProducts = <ProductModel>[].obs;
  var listCategori = [
    {'id': 0, 'name': 'All'},
    {'id': 1, 'name': 'T-Shirts'},
    {'id': 2, 'name': 'Hoodies'},
    {'id': 3, 'name': 'Jackets'},
    {'id': 4, 'name': 'Jeans'},
    {'id': 5, 'name': 'Pants'},
  ].obs;

  var selectedCategoryId = 0.obs;
  var selectedCategory = 'All'.obs;
  var searchText = ''.obs;
  @override
  void onInit() {
    fetchProduct();
    loadWishlist();
    super.onInit();
  }

  void fetchProduct() async {
    try {
      isLoading(true);
      final result = await ProductService.getAllProduct();
      for (var p in result) {
        if (p.name.toLowerCase().contains('t-shirt')) {
          p.category = 'T-Shirts';
        } else if (p.name.toLowerCase().contains('hoodie')) {
          p.category = 'Hoodies';
        } else if (p.name.toLowerCase().contains('jacket')) {
          p.category = 'Jackets';
        } else if (p.name.toLowerCase().contains('jean')) {
          p.category = 'Jeans';
        } else if (p.name.toLowerCase().contains('pant')) {
          p.category = 'Pants';
        } else {
          p.category = 'Other';
        }
      }
      products.assignAll(result);
      filterProducts();
    } catch (e) {
      throw Exception(e);
    } finally {
      isLoading(false);
    }
  }

  void filterProducts() {
    List<ProductModel> temp = products;
    if (selectedCategoryId.value != 0) {
      temp =
          temp.where((p) => p.categoryId == selectedCategoryId.value).toList();
    }
    if (searchText.value.isNotEmpty) {
      temp = temp
          .where((p) =>
              p.name.toLowerCase().contains(searchText.value.toLowerCase()) ||
              p.description
                  .toLowerCase()
                  .contains(searchText.value.toLowerCase()))
          .toList();
    }
    temp.sort((a, b) => b.id.compareTo(a.id));
    filteredProducts.assignAll(temp);
  }

  void setCategory(int id) {
    selectedCategoryId.value = id;
    filterProducts();
  }

  void setSearchText(String text) {
    searchText.value = text;
    filterProducts();
  }

  void toggleWishlist(ProductModel product) async {
    bool isAdded;
    if (wishlist.any((p) => p.id == product.id)) {
      wishlist.removeWhere((p) => p.id == product.id);
      isAdded = false;
    } else {
      wishlist.add(product);
      isAdded = true;
    }
    await saveWishlist();

    Get.snackbar(
      isAdded ? 'Added to Wishlist' : 'Removed from Wishlist',
      isAdded
          ? '${product.name} has been added to your wishlist.'
          : '${product.name} has been removed from your wishlist.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      backgroundColor: isAdded ? Colors.green : Colors.red,
      colorText: Colors.white,
    );
  }

  String get wishlistKey {
    final user = Get.find<UserController>().user.value;
    return 'wishlist_${user?.cid ?? "guest"}';
  }

  bool isWishlisted(String id) {
    return wishlist.any((p) => p.id.toString() == id);
  }

  Future<void> saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = wishlist.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(wishlistKey, wishlistJson);
  }

  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = prefs.getStringList(wishlistKey) ?? [];
    final loadedWishlist = wishlistJson
        .map((item) => ProductModel.fromJson(jsonDecode(item)))
        .toList();
    wishlist.assignAll(loadedWishlist);
  }
}
