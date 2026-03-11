import 'dart:async';

import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpForgetPsController extends GetxController {
  final int otpLength;
  final String email;

  var timerSeconds = 60.obs;
  var isResendEnabled = false.obs;
  var errorText = RxnString(null);
  var isLoading = false.obs;
  var currentOtp = ''.obs;

  late List<TextEditingController> otpControllers;
  late List<FocusNode> otpFocusNodes;

  Timer? _timer;

  OtpForgetPsController({
    required this.email,
    this.otpLength = 6,
  });

  OtpForgetPsController.fromArguments()
      : email = Get.arguments as String? ?? '',
        otpLength = 6;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _disposeControllers();
    super.onClose();
  }

  void _initializeControllers() {
    otpControllers =
        List.generate(otpLength, (index) => TextEditingController());
    otpFocusNodes = List.generate(otpLength, (index) => FocusNode());
  }

  void _disposeControllers() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
  }

  void startTimer() {
    isResendEnabled.value = false;
    timerSeconds.value = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        isResendEnabled.value = true;
        timer.cancel();
      }
    });
  }

  void updateOtp(String otp) {
    currentOtp.value = otp;
    errorText.value = null;
  }

  Future<void> verifyOtpForgetPS() async {
    if (currentOtp.value.length != otpLength) {
      errorText.value = 'Please enter complete OTP';
      return;
    }

    isLoading.value = true;
    errorText.value = null;

    try {
      final result =
          await AuthService.verifyOtpPS(email.trim(), currentOtp.value.trim());

      isLoading.value = false;

      if (result['success'] == true) {
        // Get.snackbar(
        //   'Success',
        //   result['message'] ?? 'Verification successful',
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );

        Get.toNamed(
          RoutesName.newPS,
          arguments: email,
        );
      } else {
        errorText.value = result['message'] ?? 'Invalid OTP';
      }
    } catch (e) {
      errorText.value = 'Verification failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtpForgetPS() async {
    if (!isResendEnabled.value) return;

    isLoading.value = true;

    try {
      final result = await AuthService.requestRestPS(email.trim());

      if (result['success'] == true) {
        Get.snackbar(
          'OTP Sent',
          result['message'] ?? 'New OTP has been sent to your email',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        startTimer();
        clearOtp();
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to resend OTP',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearOtp() {
    currentOtp.value = '';
    for (var controller in otpControllers) {
      controller.clear();
    }
    if (otpFocusNodes.isNotEmpty) {
      otpFocusNodes.first.requestFocus();
    }
  }
}
