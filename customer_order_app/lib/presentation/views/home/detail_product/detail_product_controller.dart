import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/data/models/card_item_model.dart';
import 'package:customer_order_app/data/models/product_model.dart';
import 'package:customer_order_app/presentation/views/cart/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailProductController extends GetxController {
  var quantity = 1.obs;
  var isLoading = false.obs;
  var selectedSize = "".obs;

  final List<String> shoeSizes = ["38", "39", "40", "41", "42", "43", "44", "45"];

  void setSelectedSize(String size) {
    selectedSize.value = size;
  }

  void incrementQuantity(int maxStock) {
    if (quantity.value < maxStock) {
      quantity.value++;
    } else {
      Get.snackbar(
        'Stock Limit',
        'Cannot add more than available stock',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
    }
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void buyNow(ProductModel product, int quantity) {
    if (selectedSize.value.isEmpty) {
      Get.snackbar(
        'Select Size',
        'Please select a size before continuing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    // 1. Create a temporary cart item
    final tempCart = [CartItem(product: product, quantity: quantity)];
    // 2. Navigate to checkout with this single item
    Get.toNamed(RoutesName.checkoutScreen, arguments: tempCart);
  }

  void addToCart(ProductModel product) {
    if (selectedSize.value.isEmpty) {
      Get.snackbar(
        'Select Size',
        'Please select a size before adding to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    final cartController = Get.find<CartController>();
    cartController.addToCart(product, quantity.value);
    Get.snackbar(
      'Added to Cart',
      'Size ${selectedSize.value} added to your cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.shopping_cart, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
    // Reset selection after adding
    selectedSize.value = "";
    quantity.value = 1;
  }
}
