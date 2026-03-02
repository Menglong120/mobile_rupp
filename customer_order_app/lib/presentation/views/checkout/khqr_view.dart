import 'dart:async';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/core/themes/themes.dart';
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

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkStatus(mock: false);
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
        title: const Text('Bakong KHQR Payment'),
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
                              'Secure Payment via Bakong',
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
                      'Waiting for payment confirmation...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
    if (qrImage != null && qrImage!.startsWith('data:image/svg+xml;base64,')) {
      return SvgPicture.memory(
        base64Decode(qrImage!.split(',').last),
        width: 250,
        height: 250,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const SizedBox(
          width: 250,
          height: 250,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Image.network(
      'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${Uri.encodeComponent(khqrString)}',
      width: 250,
      height: 250,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const SizedBox(
          width: 250,
          height: 250,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}