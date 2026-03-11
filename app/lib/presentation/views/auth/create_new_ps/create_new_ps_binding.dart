import 'package:customer_order_app/presentation/views/auth/create_new_ps/create_new_ps_controller.dart';
import 'package:get/get.dart';

class CreateNewPsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateNewPsController());
  }
}
