import 'dart:async';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/core/themes/themes.dart';
import 'package:customer_order_app/core/utils/app_constant.dart';
import 'package:http/http.dart' as http;
import 'package:customer_order_app/data/services/order_service.dart';
import 'package:customer_order_app/presentation/views/cart/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class KhqrView extends StatefulWidget {
  const KhqrView({super.key});

  @override
  State<KhqrView> createState() => _KhqrViewState();
}

class _KhqrViewState extends State<KhqrView> {
  final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;

  late final String khqrString;
  late final String? qrImage;
  late final dynamic orderId;
  late final double amount;
  late final String currency;

  Timer? _pollingTimer;
  bool _isChecking = false;
  bool _paid = false; // guard against double-redirect
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    khqrString = args['qrString'] ?? args['khqr'] ?? '';
    qrImage    = args['qrImage'];
    orderId    = args['orderId'];
    amount     = (args['total'] ?? 0.0).toDouble();
    currency   = args['currency'] ?? 'USD';

    // Start real polling — mock: false
    _startPolling();
  }

  // ── Polling ──────────────────────────────────────────────────────────────

  void _startPolling() {
    // Cancel any existing timer before starting a new one
    _pollingTimer?.cancel();

    // DEMO MODE: Auto-succeed after 5 seconds
    // This creates a REAL order in the system (like cash), just without scanning
    debugPrint('KHQR_DEMO: Starting 5-second auto-success timer...');
    _pollingTimer = Timer(const Duration(seconds: 5), () {
      _autoSucceedPayment();
    });
  }

  void _autoSucceedPayment() async {
    if (_paid || !mounted) return;
    
    debugPrint('KHQR_DEMO: Auto-succeeding payment for demo purposes');
    _pollingTimer?.cancel();

    // Mark payment as paid and finalize into a real order (like cash purchase)
    bool finalized = false;
    dynamic finalizedOrderId;
    try {
      final url = Uri.parse('$baseUrl/payments/mark-completed');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payment_request_id': orderId,
        }),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        finalized = result['success'] == true;
        finalizedOrderId = result['order_id'];
        if (finalized) {
          _paid = true;
          debugPrint('KHQR_DEMO: Payment finalized - Order #$finalizedOrderId created in database');
        } else {
          debugPrint('KHQR_DEMO: Finalize API returned non-success payload: $result');
        }
      } else {
        debugPrint('KHQR_DEMO: Failed to finalize payment: ${response.body}');
      }
    } catch (e) {
      debugPrint('KHQR_DEMO: Error finalizing payment: $e');
    }

    if (!finalized) {
      if (mounted) {
        Get.snackbar(
          'Payment Not Confirmed',
          'Could not finalize payment. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
      // Retry after a short delay to keep demo flow smooth.
      _pollingTimer = Timer(const Duration(seconds: 3), _autoSucceedPayment);
      return;
    }

    // Clear the cart
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().clearCart();
    }

    // Navigate to success screen
    Get.offAllNamed(RoutesName.orderSuccess, arguments: {
      'orderId': finalizedOrderId ?? orderId,
      'total': amount,
    });
  }

  Future<void> _checkStatus({required bool mock}) async {
    // Prevent overlapping requests and double-redirects
    if (_isChecking || _paid) return;
    _isChecking = true;

    try {
      final result = await OrderService.checkPaymentStatus(orderId, mock: mock);

      if (!mounted) return;

      // Use the flattened structure: result['status'] instead of result['data']['status']
      final status = result['status'] as String? ?? 'PENDING';

      debugPrint('BAKONG_POLL: result[success]=${result['success']}, body_status=$status');
      debugPrint('BAKONG_POLL: full_body=$result');



      if (result['success'] == true && status == 'SUCCESS') {
        debugPrint('BAKONG_POLL: SUCCESS detected! Redirecting...');
        _paid = true;
        _pollingTimer?.cancel();

        // Clear the cart
        if (Get.isRegistered<CartController>()) {
          Get.find<CartController>().clearCart();
        }

        // Navigate to success screen
        Get.offAllNamed(RoutesName.orderSuccess, arguments: {
          'orderId': orderId,
          'total': amount,
        });
      }

    } catch (e) {
      debugPrint('KhqrView: poll error: $e');
    } finally {
      _isChecking = false;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesApp.primaryColor,
      appBar: AppBar(
        title: const Text('ABA KHQR Payment'),
        centerTitle: true,
        backgroundColor: ThemesApp.primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── QR Card ─────────────────────────────────────────────────
              Screenshot(
                controller: _screenshotController,
                child: FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Scan to Pay',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currency == 'USD'
                              ? '\$${amount.toStringAsFixed(2)}'
                              : '${(amount * 4100).toStringAsFixed(0)} ៛',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2ECC71),
                          ),
                        ),
                        const SizedBox(height: 20),
              
                        // QR Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _buildQrImage(),
                        ),
              
                        const SizedBox(height: 20),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.security, color: Colors.grey, size: 16),
                            SizedBox(width: 5),
                            Text(
                              'Secure Payment via ABA KHQR',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Waiting indicator ────────────────────────────────────────
              FadeInUp(
                child: const Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Demo Mode: Processing payment...',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Order will be confirmed in 5 seconds',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '(Real order created in system - no scanning needed)',
                      style: TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              FadeInUp(
                child: TextButton.icon(
                  onPressed: _isSaving ? null : _downloadQrCode,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.download, color: Colors.white),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Download QR Code',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        _pollingTimer?.cancel();
                        Get.back();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: ThemesApp.secondaryColor,
                      ),
                      child: const Text(
                        'Cancel Payment',
                        style: TextStyle(color: ThemesApp.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadQrCode() async {
    setState(() => _isSaving = true);
    try {
      // Request permissions
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted) {
        
        final Uint8List? imageBytes = await _screenshotController.capture(
          delay: const Duration(milliseconds: 10),
          pixelRatio: 3.0,
        );

        if (imageBytes != null) {
          final tempDir = await getTemporaryDirectory();
          final fileName = "QR_Code_${DateTime.now().millisecondsSinceEpoch}.png";
          final filePath = p.join(tempDir.path, fileName);
          final file = File(filePath);
          await file.writeAsBytes(imageBytes);

          await Gal.putImage(filePath);

          Get.snackbar(
            'Success',
            'QR Code saved to gallery',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: const EdgeInsets.all(15),
          );
        }
      } else {
        Get.snackbar(
          'Permission Denied',
          'Please grant storage permission to download the QR code',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
        );
      }
    } catch (e) {
      debugPrint('Error downloading QR: $e');
      Get.snackbar(
        'Error',
        'Could not save QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildQrImage() {
    // Attempt to decode as SVG if it's base64
    if (qrImage != null && qrImage!.contains('base64,')) {
      try {
        final base64String = qrImage!.split(',').last.trim();
        final decodedBytes = base64Decode(base64String);
        
        // Peek at data: SVGs usually start with '<' or '<?xml'
        final String header = utf8.decode(decodedBytes.take(10).toList(), allowMalformed: true);
        
        if (header.contains('<')) {
          return SvgPicture.memory(
            decodedBytes,
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          );
        } else {
          // Fallback to standard Image.memory if it's PNG/JPG
          return Image.memory(
            decodedBytes,
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          );
        }
      } catch (e) {
        debugPrint('Error decoding QR Image: $e');
      }
    }

    // Fallback to generating QR via external API if base64 fails
    return Image.network(
      'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${Uri.encodeComponent(khqrString)}',
      width: 250,
      height: 250,
      fit: BoxFit.contain,
    );
  }
}