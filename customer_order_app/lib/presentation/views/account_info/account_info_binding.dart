import 'package:customer_order_app/presentation/views/account_info/account_info_controller.dart';
import 'package:get/get.dart';

class AccountInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AccountInfoController());
  }
}
