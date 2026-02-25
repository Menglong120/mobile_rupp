import 'package:customer_order_app/presentation/views/auth/otp_forget_ps/otp_forget_ps_controller.dart';
import 'package:get/get.dart';

class OtpForgetPsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpForgetPsController>(
      () => OtpForgetPsController.fromArguments(),
    );
  }
}
