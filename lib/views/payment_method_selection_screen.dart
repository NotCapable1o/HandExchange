import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'card_payment_screen.dart';
import 'mobile_banking_screen.dart';

class PaymentMethodSelectionScreen extends StatelessWidget {
  final double amount;

  const PaymentMethodSelectionScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "AamarPay Secure",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              "Payable: ৳${amount.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),

            _buildOption(
              icon: Icons.credit_card,
              title: "Visa / Mastercard",
              onTap: () async {
                final result = await Get.to(
                  () => CardPaymentScreen(amount: amount),
                );
                if (result == 'success') Get.back(result: 'success');
              },
            ),

            const Divider(color: Colors.white10, height: 40),

            _buildOption(
              icon: Icons.smartphone,
              title: "bKash / Rocket / Nagad",
              onTap: () async {
                final result = await Get.to(
                  () => MobileBankingScreen(
                    method: "Mobile Banking",
                    amount: amount,
                  ),
                );
                if (result == 'success') Get.back(result: 'success');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.blueAccent, size: 30),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white24,
        size: 16,
      ),
    );
  }
}
