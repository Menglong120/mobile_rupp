import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/data/services/auth_service.dart';
import 'package:customer_order_app/presentation/views/auth/otp_verify/otp_verify_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxBool obscurePS = true.obs;
  final RxBool obscureConfirmPS = true.obs;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var isLoading = false.obs;
  var isRememberMe = false.obs;
  var isPasswordVisible = false.obs;
  final RxBool isFormFilled = false.obs;
  late AnimationController _animationController;
  late Animation<double> shakeAnimation;

  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;

  @override
  void onInit() {
    super.onInit();

    emailController.addListener(updateFormStatus);
    passwordController.addListener(updateFormStatus);
    confirmPasswordController.addListener(updateFormStatus);

    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

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

  void updateFormStatus() {
    isFormFilled.value = emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

  @override
  void onClose() {
    _animationController.dispose();
    emailController.removeListener(updateFormStatus);
    passwordController.removeListener(updateFormStatus);
    confirmPasswordController.removeListener(updateFormStatus);
    super.onClose();
  }

  void triggerShake() {
    _animationController.forward();
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isRememberMe.value = false;
    isPasswordVisible.value = false;
  }

  void toggleRememberMe() {
    isRememberMe.value = !isRememberMe.value;
  }

  void register() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      triggerShake();
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      triggerShake();
      return;
    }

    isLoading.value = true;
    final result = await AuthService.register(
      emailController.text.trim(),
      passwordController.text,
    );
    isLoading.value = false;

    final message = result['message']?.toString() ?? '';
    if (message.contains('already exists') ||
        message.contains('already verified')) {
      Get.snackbar('Error', message);
      triggerShake();
      return;
    }

    if (result['success'] == true) {
      final email = emailController.text.trim();
      Get.put(OtpVerifyController(email: email));
      Get.toNamed(RoutesName.otpVerify, arguments: email);
      clearForm();
    } else {
      Get.snackbar(
          'Error', message.isNotEmpty ? message : 'Registration failed');
      triggerShake();
    }
  }
}
