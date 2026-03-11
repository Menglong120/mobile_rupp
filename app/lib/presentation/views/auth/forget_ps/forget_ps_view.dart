import 'package:animate_do/animate_do.dart';
import 'package:customer_order_app/core/themes/themes.dart';
import 'package:customer_order_app/presentation/views/auth/forget_ps/forget_ps_controller.dart';
import 'package:customer_order_app/presentation/widgets/custom_buttom.dart';
import 'package:customer_order_app/presentation/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPsView extends GetView<ForgetPsController> {
  ForgetPsView({super.key});
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            title: Text("Forget Password"),
            backgroundColor: Colors.white,
          ),
          body: Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  FadeInDownBig(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      "Enter your email address below and we'll send you a link to reset your password.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    hintText: "Enter your email",
                    prefixIcon: Icon(Icons.email_outlined),
                    shakeAnimation: controller.shakeAnimation,
                    controller: controller.txtEmailCtl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 45),
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: CustomButton(
                      backgroundColor: ThemesApp.secondaryColor,
                      textColor: Colors.white,
                      text: 'Submit',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          controller.submitEmailClick();
                        } else {
                          controller.triggerShake();
                        }
                      },
                    ),
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
