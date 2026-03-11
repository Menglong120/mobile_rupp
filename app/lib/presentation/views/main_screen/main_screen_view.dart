import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/core/themes/themes.dart';
import 'package:customer_order_app/presentation/controllers/user_controller.dart';
import 'package:customer_order_app/presentation/views/cart/cart_controller.dart';
import 'package:customer_order_app/presentation/views/main_screen/main_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';

class MainScreenView extends GetView<MainScreenController> {
  const MainScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: controller.currenIndex.value == 0 ? _buildAppBar() : null,
          body: IndexedStack(
            index: controller.currenIndex.value,
            children: controller.list,
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            currentIndex: controller.currenIndex.value,
            onTap: (index) => controller.currenIndex.value = index,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            selectedItemColor: ThemesApp.secondaryColor,
            items: [
              BottomNavigationBarItem(
                icon: controller.currenIndex.value == 0
                    ? Icon(
                        Icons.other_houses_rounded,
                        size: 26,
                      )
                    : Icon(
                        Icons.other_houses_outlined,
                        size: 26,
                      ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: controller.currenIndex.value == 1
                    ? Icon(
                        Icons.favorite,
                        size: 26,
                      )
                    : Icon(
                        Icons.favorite_border_outlined,
                        size: 26,
                      ),
                label: 'Wishlist',
              ),
              BottomNavigationBarItem(
                icon: controller.currenIndex.value == 2
                    ? Icon(
                        Icons.person_3_sharp,
                        size: 26,
                      )
                    : Icon(
                        Icons.person_3_outlined,
                        size: 26,
                      ),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    final user = Get.find<UserController>().user.value;
    return AppBar(
      forceMaterialTransparency: true,
      centerTitle: false,
      title: Text(
        "Hello, ${user?.fullName ?? ''}!",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Image.asset('assets/logo/Group 288870.png'),
      ),
      actions: [
        Bounceable(
          onTap: () {
            Get.toNamed(RoutesName.cartScreen);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Badge
                Positioned(
                  right: 4,
                  top: 4,
                  child: Obx(() {
                    final cartCount =
                        Get.find<CartController>().cartList.length;
                    return cartCount > 0
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '$cartCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink();
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
