import 'package:animate_do/animate_do.dart';
import 'package:customer_order_app/core/themes/themes.dart';
import 'package:customer_order_app/presentation/views/auth/signup/signup_controller.dart';
import 'package:customer_order_app/presentation/widgets/custom_buttom.dart';
import 'package:customer_order_app/presentation/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpView extends GetView<SignUpController> {
  SignUpView({super.key});
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: FadeInDown(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 100),
              child: const Text('Register'),
            ),
            centerTitle: true,
          ),
          body: Form(
            key: formKey,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Create your account to start ordering products from our app.",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 100),
                      child: CustomTextField(
                        prefixIcon: Icon(Icons.email_outlined),
                        controller: controller.emailController,
                        hintText: 'Enter your email',
                        shakeAnimation: controller.shakeAnimation,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!GetUtils.isEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Password",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 100),
                      child: AnimatedBuilder(
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
                            controller: controller.passwordController,
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
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Confirm Password",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 100),
                      child: AnimatedBuilder(
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
                            controller: controller.confirmPasswordController,
                            hintText: "Enter your confirm password",
                            obscureText: controller.obscureConfirmPS.value,
                            fieldError: controller.confirmPasswordError,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                controller.triggerShake();
                                return "Please enter your confirm password";
                              }
                              if (controller.passwordController.text !=
                                  controller.confirmPasswordController.text) {
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
                    ),
                    const SizedBox(height: 32),
                    Obx(
                      () => FadeInUpBig(
                        duration: const Duration(milliseconds: 400),
                        delay: const Duration(milliseconds: 100),
                        child: CustomButton(
                          text: 'Register',
                          backgroundColor: controller.isFormFilled.value
                              ? ThemesApp.secondaryColor
                              : ThemesApp.primaryColor,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              controller.register();
                            } else {
                              controller.triggerShake();
                            }
                          },
                          textColor: controller.isFormFilled.value
                              ? Colors.white
                              : ThemesApp.textDarkColor,
                        ),
                      ),
                    ),
                  ],
                ),
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
