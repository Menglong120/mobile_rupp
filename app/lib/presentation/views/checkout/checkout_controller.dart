import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/data/services/order_service.dart';
import 'package:customer_order_app/presentation/controllers/address_controller.dart';
import 'package:customer_order_app/presentation/controllers/user_controller.dart';
import 'package:customer_order_app/presentation/views/cart/cart_controller.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  var paymentMethod = 'cash'.obs;
  var currency = 'USD'.obs;

  // NOTE: No polling timer here — KhqrView owns its own polling.
  // This controller only places the order and navigates.

  Future<void> placeOrder(List cartItems, double total, String method) async {
    final user = Get.find<UserController>().user.value;
    final addressController = Get.find<AddressController>();
    final selectedAddress = addressController.selectedAddress.value;

    if (user == null) {
      Get.snackbar(
        'Unauthorized',
        'Please login to continue',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    if (selectedAddress == null) {
      Get.snackbar(
        'Address Required',
        'Please select a delivery address',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    final items = cartItems
        .map((item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
            })
        .toList();

    final result = await OrderService.placeOrder(
      customerId: user.cid,
      addressId: selectedAddress.id!,
      items: items,
      paymentMethod: method,
    );

    if (!result['success']) {
      Get.snackbar(
        'Order Failed',
        result['message'] ?? 'Unknown error',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    final orderId = result['data']['order_id'];

    // ── Bakong: navigate to QR screen, which handles all polling itself ──
    if (method == 'bakong') {
      final khqrResult = await OrderService.generateKhqr(
        orderId,
        currency: currency.value,
      );

      if (!khqrResult['success']) {
        Get.snackbar('Error', 'Failed to generate KHQR');
        return;
      }

      // KhqrView will start polling on its own initState
      Get.toNamed(RoutesName.khqr, arguments: {
        'qrString': khqrResult['data']['qrString'],
        'qrImage': khqrResult['data']['qrImage'],
        'orderId': orderId,
        'total': total,
        'currency': currency.value,
      });

      return; // Done — KhqrView takes over from here
    }

    // ── Cash: clear cart and go to success immediately ──
    _clearCartIfFull(cartItems);

    Get.offAllNamed(RoutesName.orderSuccess, arguments: {
      'orderId': orderId,
      'total': cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice),
    });
  }

  void _clearCartIfFull(List cartItems) {
    final cartController = Get.find<CartController>();
    final isFullCart = cartItems.length == cartController.cartList.length &&
        cartItems.every(
          (item) => cartController.cartList.any(
            (c) =>
                c.product.id == item.product.id &&
                c.quantity == item.quantity,
          ),
        );

    if (isFullCart) {
      cartController.clearCart();
    }
  }
}