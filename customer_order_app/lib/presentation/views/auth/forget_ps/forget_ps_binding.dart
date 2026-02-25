import 'package:customer_order_app/presentation/views/auth/forget_ps/forget_ps_controller.dart';
import 'package:get/get.dart';

class ForgetPsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForgetPsController());
  }
}
