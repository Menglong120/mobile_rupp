import 'package:animate_do/animate_do.dart';
import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/core/themes/themes.dart';
import 'package:customer_order_app/presentation/views/auth/login/login_controller.dart';
import 'package:customer_order_app/presentation/widgets/custom_buttom.dart';
import 'package:customer_order_app/presentation/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';

class LoginView extends GetView<LoginController> {
  LoginView({super.key});
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool isFirstLoad = true.obs;

  @override
  Widget build(BuildContext context) {
    if (isFirstLoad.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.clearForm();
        isFirstLoad.value = false;
      });
    }

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('Login'),
            centerTitle: true,
          ),
          body: Form(
            key: formKey,
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back!",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "You can log into your account first to read many interesting books!",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "Email",
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
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Password",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    FadeInUp(
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
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 16,
                            color: ThemesApp.cardColor,
                          ),
                        ),
                        SizedBox(width: 5),
                        Bounceable(
                          onTap: () {
                            Get.toNamed(RoutesName.forgetPS);
                          },
                          child: Text(
                            'Reset here',
                            style: TextStyle(
                              fontSize: 16,
                              color: ThemesApp.secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    FadeInDownBig(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 100),
                      child: CustomButton(
                        text: 'Login',
                        backgroundColor: ThemesApp.secondaryColor,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            controller.login();
                          } else {
                            controller.triggerShake();
                          }
                        },
                        textColor: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () => Get.toNamed(RoutesName.registerScreen),
                            child: Text(
                              'Register here',
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemesApp.secondaryColor,
                              ),
                            ),
                          ),
                        ],
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
