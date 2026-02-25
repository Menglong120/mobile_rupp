import 'package:customer_order_app/presentation/controllers/address_controller.dart';
import 'package:customer_order_app/presentation/views/checkout/checkout_controller.dart';
import 'package:get/get.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CheckoutController());
    Get.lazyPut(() => AddressController());
  }
}
