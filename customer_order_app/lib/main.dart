import 'dart:convert';

import 'package:customer_order_app/core/routes/routes_app.dart';
import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/presentation/controllers/theme_controller.dart';
import 'package:customer_order_app/presentation/controllers/user_controller.dart';
import 'package:customer_order_app/presentation/views/cart/cart_controller.dart';
import 'package:customer_order_app/presentation/views/main_screen/main_screen_binding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final userData = prefs.getString('userData');
  final userController = Get.put(UserController());
  if (userData != null) {
    userController.setUserFromJson(jsonDecode(userData));
  }

  Get.put(CartController());
  final themeController = Get.put(ThemeController());
  await themeController.loadThemeFromPrefs();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) async {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final themeController = Get.find<ThemeController>();
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: RoutesName.splash,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          defaultTransition: Transition.fadeIn,
          getPages: RoutesApp.routesAppp,
          initialBinding: MainScreenBinding(),
        );
      },
    );
  }
}
