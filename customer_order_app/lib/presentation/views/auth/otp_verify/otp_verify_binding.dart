import 'package:customer_order_app/presentation/views/auth/otp_verify/otp_verify_controller.dart';
import 'package:get/get.dart';

class OtpVerifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpVerifyController>(
      () => OtpVerifyController.fromArguments(),
    );
  }
}
