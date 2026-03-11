import 'dart:async';
import 'dart:convert';

import 'package:customer_order_app/core/utils/app_constant.dart';
import 'package:http/http.dart' as http;

class OrderService {
  static Future<Map<String, dynamic>> placeOrder({
    required int customerId,
    required int addressId,
    required List<Map<String, dynamic>> items,
    String paymentMethod = 'cash',
  }) async {
    final url = Uri.parse('$baseUrl/orders/place');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_id': customerId,
          'address_id': addressId,
          'items': items,
          'payment_method': paymentMethod,
        }),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getOrderHistory(int customerId) async {
    final url = Uri.parse('$baseUrl/orders/customer/$customerId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getOrderDetail(int orderId) async {
    final url = Uri.parse('$baseUrl/orders/$orderId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> generateKhqr(
    dynamic orderId, {
    String currency = 'USD',
  }) async {
    final url = Uri.parse('$baseUrl/payments/generate-khqr');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': orderId,
          'currency': currency,
        }),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> checkPaymentStatus(
    dynamic orderId, {
    bool mock = false,
  }) async {
    final url = Uri.parse('$baseUrl/payments/check-status');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': orderId,
          'mock': mock,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {'success': false, 'message': response.body};
      }

    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
    dynamic orderId,
    String status,
  ) async {
    final url = Uri.parse('$baseUrl/orders/$orderId/status');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': status,
        }),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Polls payment status every [intervalSeconds] until:
  /// - status == 'SUCCESS' → calls [onSuccess]
  /// - status == 'ERROR'   → calls [onError]
  /// - [timeoutSeconds] elapsed → calls [onTimeout]
  ///
  /// Returns a [Timer] so the caller can cancel it early (e.g. user navigates away).
  static Timer pollPaymentStatus({
    required dynamic orderId,
    required void Function() onSuccess,
    required void Function(String message) onError,
    required void Function() onTimeout,
    int intervalSeconds = 3,
    int timeoutSeconds = 900, // 15 minutes (QR expiry)
  }) {
    final stopwatch = Stopwatch()..start();

    late Timer timer;
    timer = Timer.periodic(Duration(seconds: intervalSeconds), (t) async {
      // Stop polling if we've exceeded the QR expiry time
      if (stopwatch.elapsed.inSeconds >= timeoutSeconds) {
        t.cancel();
        onTimeout();
        return;
      }

      try {
        final result = await checkPaymentStatus(orderId);

        if (!result['success']) {
          // Network/server error — keep polling, don't abort
          return;
        }

        final status = result['data']['status'] as String? ?? 'PENDING';

        if (status == 'SUCCESS') {
          t.cancel();
          onSuccess();
        } else if (status == 'ERROR') {
          t.cancel();
          onError(result['data']['message'] ?? 'Payment error');
        }
        // PENDING → do nothing, wait for next tick
      } catch (_) {
        // Silently ignore transient errors and keep polling
      }
    });

    return timer;
  }
}