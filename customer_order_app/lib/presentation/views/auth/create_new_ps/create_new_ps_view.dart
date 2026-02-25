import 'package:customer_order_app/core/themes/themes.dart';
import 'package:customer_order_app/presentation/views/auth/create_new_ps/create_new_ps_controller.dart';
import 'package:customer_order_app/presentation/widgets/custom_buttom.dart';
import 'package:customer_order_app/presentation/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateNewPsView extends GetView<CreateNewPsController> {
  CreateNewPsView({super.key});
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            forceMaterialTransparency: true,
            title: Text('Create New Password'),
          ),
          body: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Password",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: controller.shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(controller.shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: Obx(
                      () => CustomTextField(
                        prefixIcon: Icon(Icons.lock_outline),
                        controller: controller.txtPasswordCtl,
                        hintText: "Enter your password",
                        obscureText: controller.obscurePS.value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            controller.triggerShake();
                            return "Please enter your password";
                          }
                          return null;
                        },
                        suffixIcon: GestureDetector(
                          onTap: () {
                            controller.obscurePS.value =
                                !controller.obscurePS.value;
                          },
                          child: Icon(
                            controller.obscurePS.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Confirm Password",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: controller.shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(controller.shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: Obx(
                      () => CustomTextField(
                        prefixIcon: Icon(Icons.lock_outline),
                        controller: controller.txtConfirmPasswordCtl,
                        hintText: "Enter your confirm password",
                        obscureText: controller.obscureConfirmPS.value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            controller.triggerShake();
                            return "Please enter your confirm password";
                          }
                          if (controller.txtPasswordCtl.text !=
                              controller.txtConfirmPasswordCtl.text) {
                            controller.triggerShake();
                            return "Confirm password not match";
                          }
                          return null;
                        },
                        suffixIcon: GestureDetector(
                          onTap: () {
                            controller.obscureConfirmPS.value =
                                !controller.obscureConfirmPS.value;
                          },
                          child: Icon(
                            controller.obscureConfirmPS.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 45),
                  CustomButton(
                    backgroundColor: ThemesApp.secondaryColor,
                    textColor: Colors.white,
                    text: 'Submit',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.changePasswordClick();
                      } else {
                        controller.triggerShake();
                      }
                    },
                  ),
                ],
              ),
            ),
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
}
