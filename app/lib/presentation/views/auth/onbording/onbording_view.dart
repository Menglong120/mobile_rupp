import 'package:animate_do/animate_do.dart';
import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/core/themes/themes.dart';
import 'package:customer_order_app/presentation/views/auth/onbording/onbording_controller.dart';
import 'package:customer_order_app/presentation/widgets/custom_buttom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ThemesApp.textHintColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Center(
                child: Container(
                  height: height * 0.5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade300,
                  ),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 300),
                    delay: const Duration(milliseconds: 100),
                    child: Image.asset(
                      'assets/logo/cover.png',
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              FadeInLeft(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Welcome to ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemesApp.textDarkColor,
                  ),
                ),
              ),
              SizedBox(height: 16),
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Discover the best products and services tailored just for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: ThemesApp.cardColor),
                ),
              ),
              Spacer(),
              FadeInDownBig(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                child: CustomButton(
                  text: 'Get Start',
                  onPressed: () {
                    Get.toNamed(RoutesName.loginScreen);
                  },
                  backgroundColor: ThemesApp.secondaryColor,
                  borderRadius: 20,
                  textColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              FadeInUpBig(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                child: CustomButton(
                  text: "I'm new, sign me up",
                  onPressed: () {
                    Get.toNamed(RoutesName.registerScreen);
                  },
                  borderRadius: 20,
                  outlineColor: Colors.grey.shade400,
                  textColor: ThemesApp.textDarkColor,
                  value: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
