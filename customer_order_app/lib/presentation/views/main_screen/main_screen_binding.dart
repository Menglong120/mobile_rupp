import 'package:customer_order_app/presentation/views/home/home_screen/home_controller.dart';
import 'package:customer_order_app/presentation/views/main_screen/main_screen_controller.dart';
import 'package:customer_order_app/presentation/views/setting/setting_controller.dart';
import 'package:customer_order_app/presentation/views/wishlist/wishlist_controller.dart';
import 'package:get/get.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainScreenController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => WishlistController());
    Get.lazyPut(() => SettingController());
  }
}
