import 'dart:convert';
import 'dart:io';

import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/data/services/auth_service.dart';
import 'package:customer_order_app/presentation/controllers/user_controller.dart';
import 'package:customer_order_app/presentation/views/cart/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupAccountController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final fullName = TextEditingController();
  final phone = TextEditingController();
  final Rx<String> selectedGender = ''.obs;
  final isFormValid = false.obs;
  final RxBool isFormFilled = false.obs;
  late AnimationController _animationController;
  late Animation<double> shakeAnimation;

  var isLoading = false.obs;

  final picker = ImagePicker();

  final imageUrl = ''.obs;
  final imageFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    fullName.addListener(checkFormValidity);
    phone.addListener(checkFormValidity);
    selectedGender.listen((_) => checkFormValidity());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticIn,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
  }

  Future<void> submitAccountSetup() async {
    isLoading.value = true;

    final result = await AuthService.setupAccount(
      fullName: fullName.text.trim(),
      email: Get.arguments ?? '',
      gender: selectedGender.value,
      phone: phone.text.trim(),
      photoFile: imageFile.value,
    );
    isLoading.value = false;

    if (result['success'] == true) {
      if (result['data'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userData', jsonEncode(result['data']));
        final userController = Get.find<UserController>();
        userController.setUserFromJson(result['data']);
        Get.find<CartController>().loadCart();
      }
      Get.offAllNamed(RoutesName.loginScreen);
    } else {
      Get.snackbar('Error',
          result['error'] ?? result['message'] ?? 'Account setup failed');
      triggerShake();
    }
  }

  void profileClick() async {
    var image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (image == null) return;
    imageFile.value = File(image.path);
  }

  void triggerShake() {
    _animationController.forward();
  }

  void checkFormValidity() {
    isFormValid.value = fullName.text.isNotEmpty &&
        phone.text.isNotEmpty &&
        selectedGender.value.isNotEmpty;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }

  void updateGender(String gender) {
    selectedGender.value = gender;
  }

  @override
  void onClose() {
    fullName.dispose();
    phone.dispose();
    super.onClose();
  }
}
