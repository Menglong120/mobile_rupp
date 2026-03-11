import 'package:get/get.dart';

class CustomSize {
  // Use Get.width and Get.height to ensure they are always available
  static double get screenWidth => Get.width;
  static double get screenHeight => Get.height;

  // Helper methods for responsive sizes
  static double height(double height) {
    return screenHeight * (height / 812.0);
  }

  static double width(double width) {
    return screenWidth * (width / 375.0);
  }
}
