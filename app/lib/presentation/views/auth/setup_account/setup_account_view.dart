import 'package:customer_order_app/core/themes/themes.dart';
import 'package:customer_order_app/presentation/views/auth/setup_account/setup_account_controller.dart';
import 'package:customer_order_app/presentation/widgets/custom_buttom.dart';
import 'package:customer_order_app/presentation/widgets/custom_dropdown.dart';
import 'package:customer_order_app/presentation/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';

class SetupAccountView extends GetView<SetupAccountController> {
  SetupAccountView({super.key});

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            forceMaterialTransparency: true,
            backgroundColor: Colors.white,
            title: Text('Setup Account'),
          ),
          body: Form(
            key: formKey,
            child: Obx(() {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Setup your account',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'setup your account first before you can use this account',
                      style: TextStyle(),
                    ),
                    const SizedBox(height: 32),
                    _buildUserImage(),
                    const SizedBox(height: 12),
                    Center(
                      child: Bounceable(
                        onTap: () => controller.profileClick(),
                        child: Text(
                          "Change photo profile",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Text('Full name'),
                    SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: controller.shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(controller.shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: CustomTextField(
                        controller: controller.fullName,
                        hintText: 'Enter full name',
                        validator: controller.validateFullName,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text('Gender'),
                    SizedBox(height: 8),
                    GenderDropdown(
                      labelText: 'Gender',
                      selectedGender: controller.selectedGender.value,
                      onChanged: (value) {
                        if (value != null) controller.updateGender(value);
                      },
                      validator: controller.validateGender,
                      genderOptions: const ['male', 'female', 'other'],
                    ),
                    const SizedBox(height: 24),
                    Text('Phone Number'),
                    SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: controller.shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(controller.shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: CustomTextField(
                        keyboardtype: TextInputType.numberWithOptions(),
                        controller: controller.phone,
                        hintText: 'Enter phone number',
                        validator: controller.validatePhone,
                      ),
                    ),
                    SizedBox(height: 40),
                    CustomButton(
                      text: "Submit",
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          // Get.toNamed(RoutesName.successAcc);
                          controller.submitAccountSetup();
                        } else {
                          controller.triggerShake();
                        }
                      },
                      backgroundColor: ThemesApp.textSuccessColor,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        Obx(
          () => controller.isLoading.value
              ? Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildUserImage() {
    Widget imageWidget = Icon(Icons.person, color: Colors.white, size: 48);

    if (controller.imageFile.value != null) {
      imageWidget = Image.file(controller.imageFile.value!, fit: BoxFit.cover);
    } else if (controller.imageUrl.value.isNotEmpty) {
      imageWidget = Image.network(
        controller.imageUrl.value,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, color: Colors.white, size: 48);
        },
      );
    }

    return Center(
      child: GestureDetector(
        onTap: controller.profileClick,
        child: Container(
          width: 96,
          height: 96,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: imageWidget,
        ),
      ),
    );
  }
}
