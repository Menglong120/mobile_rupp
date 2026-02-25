import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var txtEmailCtl = TextEditingController();
  final RxBool isFormFilled = false.obs;

  var isLoading = false.obs;

  late AnimationController _animationController;
  late Animation<double> shakeAnimation;

  @override
  void onInit() {
    super.onInit();

    txtEmailCtl.addListener(updateFormStatus);

    txtEmailCtl.clear();

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

  // void submitEmailClick() {
  //   if (txtEmailCtl.text.isEmpty) {
  //     _animationController.forward();
  //   } else {
  //     Get.toNamed(RoutesName.otpForgetPsVerify);
  //   }
  // }

  Future<void> submitEmailClick() async {
    final email = txtEmailCtl.text.trim();

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      triggerShake();
      return;
    }

    isLoading.value = true;

    try {
      // Call existing backend to request reset password (sends OTP if email exists)
      final result = await AuthService.requestRestPS(email);

      if (result['success'] == true) {
        Get.snackbar(
          'Success',
          result['message'] ?? 'OTP sent to your email',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to OTP verify screen with email
        Get.toNamed(RoutesName.otpForgetPsVerify, arguments: email);
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Email not found or request failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        triggerShake();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Server error, please try again',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      triggerShake();
    } finally {
      isLoading.value = false;
    }
  }

  void updateFormStatus() {
    isFormFilled.value = txtEmailCtl.text.isNotEmpty;
  }

  @override
  void onClose() {
    _animationController.dispose();
    txtEmailCtl.removeListener(updateFormStatus);
    super.onClose();
  }

  void triggerShake() {
    _animationController.forward();
  }

  void clearForm() {
    txtEmailCtl.clear();
  }
}
