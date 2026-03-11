import 'dart:convert';

import 'package:customer_order_app/data/models/card_item_model.dart';
import 'package:customer_order_app/data/models/product_model.dart';
import 'package:customer_order_app/presentation/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartController extends GetxController {
  var cartList = <CartItem>[].obs;

  String get _cartKey {
    final user = Get.find<UserController>().user.value;
    return 'cart_${user?.cid ?? "guest"}';
  }

  @override
  void onInit() {
    super.onInit();
    loadCart();
    ever(cartList, (_) => saveCart());
  }

  void addToCart(ProductModel product, int quantity) {
    int index = cartList.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      int newQty = cartList[index].quantity + quantity;
      if (newQty <= product.stock) {
        cartList[index] = CartItem(product: product, quantity: newQty);
      }
    } else {
      cartList.add(CartItem(product: product, quantity: quantity));
    }
  }

  void removeFromCart(int index) {
    cartList.removeAt(index);
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = cartList.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_cartKey, cartJson);
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getStringList(_cartKey) ?? [];
    final loadedCart =
        cartJson.map((item) => CartItem.fromJson(jsonDecode(item))).toList();
    cartList.assignAll(loadedCart);
  }

  void clearCart() {
    cartList.clear();
  }
}
