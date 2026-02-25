import 'package:animate_do/animate_do.dart';
import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/data/services/auth_service.dart';
import 'package:customer_order_app/presentation/controllers/user_controller.dart';
import 'package:customer_order_app/presentation/views/setting/setting_controller.dart';
import 'package:customer_order_app/presentation/widgets/setting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<UserController>().user.value;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        forceMaterialTransparency: true,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          children: [
            Center(
              child: Column(
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: (user!.photo.isNotEmpty)
                          ? NetworkImage(user.photo)
                          : null,
                      child: (user.photo.isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Verified Profile",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Account"),
            const SizedBox(height: 8),
            Bounceable(
              onTap: () => Get.toNamed(RoutesName.accountInfo),
              child: SettingCard(
                value: null,
                title: 'Account Info',
                icon: Icons.info_outline,
              ),
            ),
            Bounceable(
              onTap: () {
                Get.toNamed(RoutesName.forgetPS);
              },
              child: SettingCard(
                value: null,
                title: 'Password',
                icon: Icons.lock_outline,
              ),
            ),
            Bounceable(
              onTap: () => Get.toNamed(RoutesName.addressListScreen),
              child: SettingCard(
                value: null,
                title: 'Shipping Address',
                icon: Icons.location_on_outlined,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Orders"),
            const SizedBox(height: 8),
            Bounceable(
              onTap: () => Get.toNamed(RoutesName.orderHistory),
              child: SettingCard(
                value: null,
                title: 'My Order',
                icon: Icons.history,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("General"),
            const SizedBox(height: 8),
            SettingCard(
              value: null,
              title: 'Settings',
              icon: Icons.settings,
            ),
            Bounceable(
              onTap: () {
                Get.toNamed(RoutesName.aboutUs);
              },
              child: SettingCard(
                value: null,
                title: 'About Us',
                icon: Icons.info_outline,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Bounceable(
                onTap: () => _showLogoutDialog(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_outlined, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text(
              'Logout',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              AuthService.logout();
              Get.offAllNamed(RoutesName.onBording);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
