import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateNewPsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var isLoading = false.obs;
  final RxBool obscurePS = true.obs;
  final RxBool obscureConfirmPS = true.obs;
  var txtEmail = TextEditingController();

  var txtPasswordCtl = TextEditingController();
  var txtConfirmPasswordCtl = TextEditingController();
  final RxBool isFormFilled = false.obs;

  late AnimationController _animationController;
  late Animation<double> shakeAnimation;

  @override
  void onInit() {
    super.onInit();

    txtPasswordCtl.addListener(updateFormStatus);
    txtConfirmPasswordCtl.addListener(updateFormStatus);

    txtPasswordCtl.clear();
    txtConfirmPasswordCtl.clear();

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

  Future<void> changePasswordClick() async {
    if (txtPasswordCtl.text.isEmpty || txtConfirmPasswordCtl.text.isEmpty) {
      triggerShake();
      return;
    }

    if (txtPasswordCtl.text != txtConfirmPasswordCtl.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      triggerShake();
      return;
    }

    isLoading.value = true;

    try {
      final result = await AuthService.resetPassword(
        email: Get.arguments ?? '',
        newPassword: txtPasswordCtl.text.trim(),
        passwordConfirmation: txtConfirmPasswordCtl.text.trim(),
      );

      if (result['success'] == true) {
        Get.snackbar(
          'Success',
          result['message'] ?? 'Password changed successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        Get.offAllNamed(RoutesName.loginScreen);
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to reset password',
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
    isFormFilled.value = txtPasswordCtl.text.isNotEmpty;
    isFormFilled.value = txtConfirmPasswordCtl.text.isNotEmpty;
  }

  @override
  void onClose() {
    _animationController.dispose();
    txtPasswordCtl.removeListener(updateFormStatus);
    txtConfirmPasswordCtl.removeListener(updateFormStatus);
    super.onClose();
  }

  void triggerShake() {
    _animationController.forward();
  }

  void clearForm() {
    txtPasswordCtl.clear();
    txtConfirmPasswordCtl.clear();
  }
}
