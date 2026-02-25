import 'package:customer_order_app/presentation/views/auth/otp_forget_ps/otp_forget_ps_controller.dart';
import 'package:customer_order_app/presentation/widgets/custom_otpInput.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpForgetPsView extends GetView<OtpForgetPsController> {
  OtpForgetPsView({super.key});
  late double screenHeight;
  late double screenWidth;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            forceMaterialTransparency: true,
            title: const Text(
              'OTP Verification',
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 40,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We sent a verification code to\n${controller.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                CustomOtpInput(
                  length: controller.otpLength,
                  controllers: controller.otpControllers,
                  focusNodes: controller.otpFocusNodes,
                  onChanged: (otp) => controller.updateOtp(otp),
                  onCompleted: (otp) => controller.verifyOtpForgetPS(),
                  width: 45,
                  height: 55,
                  spacing: 12,
                  borderRadius: 12,
                  fillColor: Colors.grey.shade50,
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: Colors.blue.shade600,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  return controller.errorText.value != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            controller.errorText.value!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                }),
                const SizedBox(height: 32),
                // SizedBox(
                //   width: double.infinity,
                //   height: 50,
                //   child: Obx(() {
                //     return ElevatedButton(
                //       onPressed: controller.currentOtp.value.length ==
                //               controller.otpLength
                //           ? () => controller.verifyOtpForgetPS()
                //           : null,
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.blue.shade600,
                //         foregroundColor: Colors.white,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(12),
                //         ),
                //       ),
                //       child: const Text(
                //         'Verify OTP',
                //         style: TextStyle(
                //             fontSize: 16, fontWeight: FontWeight.w600),
                //       ),
                //     );
                //   }),
                // ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    Obx(() {
                      return controller.isResendEnabled.value
                          ? GestureDetector(
                              onTap: () => controller.resendOtpForgetPS(),
                              child: Text(
                                'Resend',
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : Text(
                              'Resend in ${controller.timerSeconds.value}s',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
        Obx(() {
          return controller.isLoading.value
              ? Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink();
        }),
      ],
    );
  }
}
