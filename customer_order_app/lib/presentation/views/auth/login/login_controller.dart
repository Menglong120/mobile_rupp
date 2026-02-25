import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/data/services/auth_service.dart';
import 'package:customer_order_app/presentation/controllers/user_controller.dart';
import 'package:customer_order_app/presentation/views/cart/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxBool obscurePS = true.obs;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var isLoading = false.obs;
  var isRememberMe = false.obs;
  var isPasswordVisible = false.obs;

  late AnimationController _animationController;
  late Animation<double> shakeAnimation;

  @override
  void onInit() {
    super.onInit();

    emailController.clear();
    passwordController.clear();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });

    clearForm();
  }

  void triggerShake() {
    _animationController.forward();
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    isRememberMe.value = false;
    isPasswordVisible.value = false;
  }

  void toggleRememberMe() {
    isRememberMe.value = !isRememberMe.value;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      triggerShake();
      return;
    }

    isLoading.value = true;

    final result = await AuthService.login(
      emailController.text.trim(),
      passwordController.text,
    );

    isLoading.value = false;

    if (result['success'] == true) {
      final userController = Get.find<UserController>();
      userController.setUserFromJson(result['data']);
      await Get.find<CartController>().loadCart();
      Get.offAllNamed(RoutesName.mainScreen);
    } else {
      Get.snackbar(
        'Login Failed',
        'email or password invalid',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }
}
