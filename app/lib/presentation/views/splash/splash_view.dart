import 'package:customer_order_app/presentation/views/splash/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/Group 288870.png',
              fit: BoxFit.cover,
              height: 150,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}
