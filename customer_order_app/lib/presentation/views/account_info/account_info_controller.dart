// account_info_controller.dart
import 'dart:io';

import 'package:customer_order_app/data/models/user_model.dart';
import 'package:customer_order_app/data/services/auth_service.dart';
import 'package:customer_order_app/presentation/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AccountInfoController extends GetxController {
  final UserController userController = Get.find<UserController>();
  final ImagePicker _picker = ImagePicker();

  RxBool isLoading = false.obs;
  RxBool isUploadingPhoto = false.obs;
  Rxn<File> selectedImage = Rxn<File>();

  UserModel? get user => userController.user.value;

  @override
  void onInit() {
    super.onInit();
    // Load user data if needed
    loadUserData();
  }

  void loadUserData() {
    // If user data is not loaded, you might want to fetch it here
    // This depends on your app's architecture
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await updateUserPhoto();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await updateUserPhoto();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take picture: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateUserPhoto() async {
    if (selectedImage.value == null || user?.email.isEmpty == true) return;

    isUploadingPhoto.value = true;

    try {
      // Call your API service updatePhoto method
      final result = await AuthService.updatePhoto(
        email: user!.email,
        photoFile: selectedImage.value!,
      );

      if (result['success'] == true) {
        // Update user data with new photo URL if provided
        if (result['data'] != null && result['data']['photo_url'] != null) {
          final updatedUser = UserModel(
            cid: user!.cid,
            fullName: user!.fullName,
            gender: user!.gender,
            phone: user!.phone,
            email: user!.email,
            photo: result['data']['photo_url'],
          );
          userController.setUser(updatedUser);
        }

        Get.snackbar(
          'Success',
          result['message'] ?? 'Photo updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          result['error'] ?? 'Failed to update photo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploadingPhoto.value = false;
      selectedImage.value = null;
    }
  }

  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                    takePicture();
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('Camera'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    pickImage();
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.photo_library, size: 40, color: Colors.green),
                      SizedBox(height: 8),
                      Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
