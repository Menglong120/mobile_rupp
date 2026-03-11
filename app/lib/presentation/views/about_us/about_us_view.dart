import 'package:animate_do/animate_do.dart';
import 'package:customer_order_app/core/themes/themes.dart';
import 'package:customer_order_app/presentation/views/about_us/about_us_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutUsView extends GetView<AboutUsController> {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesApp.primaryColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: ThemesApp.primaryColor,
        title: const Text(
          'Meet Our Team',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              'We are passionate about building great products.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
                children: [
                  FadeInDownBig(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: _buildMemberCard(
                      imageUrl: 'assets/aboutus/anbunkhim.png',
                      name: 'An Bunkhim',
                      position: 'Mobile Developer',
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: _buildMemberCard(
                      imageUrl: 'assets/aboutus/long.jpg',
                      name: 'Bo Menglong',
                      position: 'Web Developer',
                    ),
                  ),
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: _buildMemberCard(
                      imageUrl: 'assets/aboutus/rith.png',
                      name: 'Pon Channarith',
                      position: 'Spring Boot Developer',
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: _buildMemberCard(
                      imageUrl: 'assets/aboutus/try.png',
                      name: 'Phon Soytry',
                      position: 'IT Support',
                    ),
                  ),
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: _buildMemberCard(
                      imageUrl: 'assets/aboutus/rothana.png',
                      name: 'Sorn Visal',
                      position: 'IT Support',
                    ),
                  ),
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: _buildMemberCard(
                      imageUrl: 'assets/aboutus/rothana.png',
                      name: 'Phon Rothana',
                      position: 'Spring Boot Developer',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard({
    required String imageUrl,
    required String name,
    required String position,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(imageUrl),
            radius: 50,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            position,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
