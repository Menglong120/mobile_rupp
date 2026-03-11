import 'package:customer_order_app/presentation/views/auth/setup_account/setup_account_controller.dart';
import 'package:get/get.dart';

class SetupAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SetupAccountController());
  }
}
