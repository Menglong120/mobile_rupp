import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/data/models/user_model.dart';
import 'package:customer_order_app/data/services/auth_service.dart';
import 'package:customer_order_app/presentation/controllers/user_controller.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    checkAuthAndNavigate();
  }

  Future<void> checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final isLoggedIn = await AuthService.isLoggedIn();

    if (isLoggedIn) {
      final data = await AuthService.getSavedUserData();
      if (data != null) {
        final userController = Get.find<UserController>();
        userController.setUser(UserModel.fromJson(data));

        Get.offNamed(RoutesName.mainScreen);
        return;
      }
    }

    Get.offNamed(RoutesName.onBording);
  }
}
