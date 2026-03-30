import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:lottie/lottie.dart';

import '../controllers/cart_controller.dart';
import 'main_wrapper.dart';

class MobileBankingScreen extends StatefulWidget {
  final String method;
  final double amount;

  const MobileBankingScreen({
    super.key,
    required this.method,
    required this.amount,
  });

  @override
  State<MobileBankingScreen> createState() => _MobileBankingScreenState();
}

class _MobileBankingScreenState extends State<MobileBankingScreen> {
  int step = 1;
  int _seconds = 30;
  Timer? _timer;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final pinController = TextEditingController();

  final String revenueAnim =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Revenue.json";
  final String successAnim =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Tick%20Market.json";

  @override
  void dispose() {
    _timer?.cancel();
    phoneController.dispose();
    otpController.dispose();
    pinController.dispose();
    super.dispose();
  }

  bool _isValidBDNumber(String number) {
    RegExp regex = RegExp(r'^(013|014|015|016|017|018|019)\d{8}$');
    return regex.hasMatch(number);
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 30);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        t.cancel();
      }
    });
  }

  void _handleSuccess() async {
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    setState(() => step = 4);

    try {
      Get.find<CartController>().clearCart();
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.offAll(() => const MainWrapper());
    });
  }

  void _handleBack() {
    FocusScope.of(context).unfocus();

    if (step == 1) {
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.back();
      });
      return;
    }

    if (step == 4) return;

    _timer?.cancel();
    setState(() => step--);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _handleBack,
          ),
          title: Text(
            widget.method,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (step < 4) ...[
                  Lottie.network(revenueAnim, height: 180),
                  const Text(
                    "Payable Amount",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "৳ ${widget.amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildBodyContent(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(bool isDark) {
    switch (step) {
      case 1:
        return _buildPhoneUI(isDark);
      case 2:
        return _buildOTPUI(isDark);
      case 3:
        return _buildPINUI(isDark);
      case 4:
        return _buildSuccessUI();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhoneUI(bool isDark) {
    return Column(
      key: const ValueKey(1),
      children: [
        Text(
          "Enter Mobile Number",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        PinCodeTextField(
          appContext: context,
          length: 11,
          controller: phoneController,
          keyboardType: TextInputType.number,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12),
            fieldHeight: 45,
            fieldWidth: 26,
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.grey,
          ),
          onChanged: (_) {},
        ),
        const SizedBox(height: 30),
        _animatedButton("SEND OTP", () {
          if (phoneController.text.isEmpty) {
            _showWarning("Field Required", "Please enter your mobile number");
          } else if (!_isValidBDNumber(phoneController.text)) {
            _showWarning(
              "Invalid Number",
              "Enter a valid 11-digit BD number (013-019)",
            );
          } else {
            setState(() => step = 2);
            _startTimer();
          }
        }),
      ],
    );
  }

  Widget _buildOTPUI(bool isDark) {
    return Column(
      key: const ValueKey(2),
      children: [
        Text(
          "Verify Number: ${phoneController.text}",
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        PinCodeTextField(
          appContext: context,
          length: 6,
          controller: otpController,
          keyboardType: TextInputType.number,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12),
            fieldHeight: 50,
            fieldWidth: 45,
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.grey,
          ),
          onChanged: (_) {},
        ),
        const SizedBox(height: 15),
        _seconds > 0
            ? Text(
                "Resend code in ${_seconds}s",
                style: const TextStyle(color: Colors.grey),
              )
            : TextButton(
                onPressed: _startTimer,
                child: const Text("Resend OTP"),
              ),
        const SizedBox(height: 30),
        _animatedButton("VERIFY", () {
          if (otpController.text.isEmpty) {
            _showWarning("OTP Required", "Please enter the 6-digit OTP");
          } else if (otpController.text == "123456") {
            setState(() => step = 3);
          } else {
            _showWarning("Invalid OTP", "Try default OTP: 123456");
          }
        }),
      ],
    );
  }

  Widget _buildPINUI(bool isDark) {
    return Column(
      key: const ValueKey(3),
      children: [
        const Text(
          "Enter 8-Digit Transaction PIN",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        PinCodeTextField(
          appContext: context,
          length: 8,
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.underline,
            fieldHeight: 50,
            fieldWidth: 30,
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.grey,
          ),
          onChanged: (_) {},
        ),
        const SizedBox(height: 40),
        _animatedButton("CONFIRM & PAY", () {
          if (pinController.text.isEmpty) {
            _showWarning("PIN Required", "Please enter your PIN to proceed");
          } else if (pinController.text == "12105007") {
            _handleSuccess();
          } else {
            _showWarning("Incorrect PIN", "The PIN you entered is invalid");
          }
        }, color: Colors.green),
      ],
    );
  }

  Widget _buildSuccessUI() {
    return SizedBox(
      key: const ValueKey(4),
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(successAnim, height: 250, repeat: false),
          const SizedBox(height: 20),
          const Text(
            "Payment Successful!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Your cart has been cleared.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _animatedButton(
    String text,
    VoidCallback onTap, {
    Color color = Colors.blue,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _showWarning(String title, String msg) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 2),
    );
  }
}
