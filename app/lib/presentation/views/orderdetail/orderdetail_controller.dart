import 'package:customer_order_app/core/utils/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderdetailController extends GetxController {
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF2ECC71);
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String getImageUrl(String image) {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    final needsSlash = !image.startsWith('/');
    return '$serverBaseUrl${needsSlash ? '/' : ''}$image';
  }
}
