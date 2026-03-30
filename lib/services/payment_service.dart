import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../views/payment_webview_screen.dart';
import '../widgets/animated_assets.dart';

class PaymentService {
  static final String loadingLottie =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/loading.json";
  static final String successLottie =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Tick%20Market.json";

  static void showOrderSummary(
    BuildContext context,
    double subtotal,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    double platformFee = subtotal * 0.02;
    double grandTotal = subtotal + platformFee;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              _invoiceRow("Subtotal", subtotal, subtitleColor, textColor),
              const SizedBox(height: 10),
              _invoiceRow(
                "Service Charge (2%)",
                platformFee,
                subtitleColor,
                textColor,
              ),
              const Divider(height: 30),
              _invoiceRow(
                "Grand Total",
                grandTotal,
                textColor,
                Colors.blueAccent,
                isTotal: true,
              ),
              const SizedBox(height: 30),

              AnimatedAssets.tapEffect(
                onTap: () {
                  Navigator.pop(context);
                  _startAamarPaySelection(
                    context,
                    grandTotal,
                    cardColor,
                    textColor,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      "Secure Checkout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _startAamarPaySelection(
    BuildContext context,
    double amount,
    Color cardColor,
    Color textColor,
  ) async {
    final AuthController authController = Get.find<AuthController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.network(loadingLottie, height: 120),
              Text("Loading AamarPay...", style: TextStyle(color: textColor)),
            ],
          ),
        ),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse("https://sandbox.aamarpay.com/jsonpost.php"),
        body: jsonEncode({
          "store_id": "aamarpaytest",
          "signature_key": "dbb74894e82415a2f7ff0ec3a97e4183",
          "tran_id": "TRX_${DateTime.now().millisecondsSinceEpoch}",
          "amount": amount.toStringAsFixed(2),
          "currency": "BDT",
          "cus_name": "User",
          "cus_email":
              authController.supabase.auth.currentUser?.email ??
              "test@test.com",
          "cus_phone": "01700000000",
          "desc": "Purchase",
          "success_url": "https://www.google.com/success",
          "fail_url": "https://www.google.com/fail",
          "cancel_url": "https://www.google.com/cancel",
          "type": "json",
        }),
      );

      if (context.mounted) Navigator.pop(context);

      final data = jsonDecode(response.body);

      if (data['result'] == 'true') {
        final result = await Get.to(
          () => PaymentWebViewScreen(url: data['payment_url'], amount: amount),
        );

        if (result == 'success') {
          await Get.find<CartController>().clearCart();
          if (context.mounted)
            _showSuccessDialog(context, cardColor, textColor);
        } else if (result == 'cancel' || result == null) {
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.snackbar(
              "Payment",
              "Transaction cancelled or closed",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
          });
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      Get.snackbar("Error", "Payment Initialization Failed: $e");
    }
  }

  static void _showSuccessDialog(
    BuildContext context,
    Color cardColor,
    Color textColor,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.network(successLottie, height: 150, repeat: false),
              const Text(
                "Payment Successful!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Done"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _invoiceRow(
    String title,
    double amount,
    Color titleColor,
    Color amountColor, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: titleColor,
          ),
        ),
        Text(
          "৳${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: isTotal ? 22 : 16,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
