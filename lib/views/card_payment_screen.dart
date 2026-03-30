import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../controllers/cart_controller.dart';
import 'main_wrapper.dart';

class CardPaymentScreen extends StatefulWidget {
  final double amount;
  const CardPaymentScreen({super.key, required this.amount});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  int step = 1;
  int _seconds = 30;
  Timer? _timer;

  late TextEditingController cardNoController;
  late TextEditingController phoneController;
  late TextEditingController otpController;
  late TextEditingController pinController;

  String selectedMonth = "05";
  String selectedYear = "2026";

  final List<String> months = List.generate(
    12,
    (i) => (i + 1).toString().padLeft(2, '0'),
  );
  final List<String> years = List.generate(10, (i) => (2025 + i).toString());

  final String cardAnim =
      "https://assets10.lottiefiles.com/packages/lf20_5ngs2ksb.json";
  final String successAnim =
      "https://assets10.lottiefiles.com/packages/lf20_pqnfmone.json";
  final String visaCard =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Cards%20payment.json";
  @override
  void initState() {
    super.initState();
    cardNoController = TextEditingController();
    phoneController = TextEditingController();
    otpController = TextEditingController();
    pinController = TextEditingController();
  }

  @override
  void dispose() {
    _timer?.cancel();
    cardNoController.dispose();
    phoneController.dispose();
    otpController.dispose();
    pinController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (!mounted) return;
    setState(() => _seconds = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted && _seconds > 0) {
        setState(() => _seconds--);
      } else {
        t.cancel();
      }
    });
  }

  bool _isValidBDNumber(String number) {
    RegExp regex = RegExp(r'^(013|014|015|016|017|018|019)\d{8}$');
    return regex.hasMatch(number);
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
      Get.back();
      return;
    }
    if (step == 4) return;
    _timer?.cancel();
    setState(() => step--);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _handleBack,
          ),
          centerTitle: true,
          title: Text(
            "Card Payment",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(isDark),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _buildStepContent(isDark, cardColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    String anim;
    if (step == 1) {
      anim = visaCard;
    } else if (step >= 2 && step <= 3) {
      anim = cardAnim;
    } else {
      anim = successAnim;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Lottie.network(
            anim,
            height: 140,
            repeat: step != 4,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.credit_card,
              size: 100,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 10),
          if (step < 4) ...[
            const Text(
              "Total Payable",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              "৳ ${widget.amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepContent(bool isDark, Color cardColor) {
    switch (step) {
      case 1:
        return _buildCardForm(isDark, cardColor);
      case 2:
        return _buildOTPForm(isDark);
      case 3:
        return _buildPINForm(isDark);
      case 4:
        return _buildSuccessUI();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCardForm(bool isDark, Color cardColor) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputLabel("Card Number", isDark),
        TextField(
          controller: cardNoController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            CardNumberFormatter(),
          ],
          decoration: _inputDecoration(
            "0000 0000 0000 0000",
            Icons.credit_card,
            cardColor,
            isDark,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _inputLabel("Expiry Month", isDark),
                  DropdownButtonFormField(
                    value: selectedMonth,
                    dropdownColor: cardColor,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: _inputDecoration("", null, cardColor, isDark),
                    items: months
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedMonth = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _inputLabel("Expiry Year", isDark),
                  DropdownButtonFormField(
                    value: selectedYear,
                    dropdownColor: cardColor,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: _inputDecoration("", null, cardColor, isDark),
                    items: years
                        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedYear = v!),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _inputLabel("Phone Number", isDark),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: _inputDecoration(
            "01601XXXXXX",
            Icons.phone_android,
            cardColor,
            isDark,
          ),
        ),
        const SizedBox(height: 40),
        _animatedButton("PROCEED TO OTP", () {
          if (cardNoController.text.replaceAll(' ', '').length < 16) {
            _showWarning("Invalid Card", "Enter 16-digit card number");
          } else if (!_isValidBDNumber(phoneController.text)) {
            _showWarning("Invalid Phone", "Enter valid BD number (013-019)");
          } else {
            setState(() => step = 2);
            _startTimer();
          }
        }),
      ],
    );
  }

  Widget _buildOTPForm(bool isDark) {
    return Column(
      key: const ValueKey(2),
      children: [
        Text(
          "OTP Verification",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "We sent a code to ${phoneController.text}",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 30),
        PinCodeTextField(
          appContext: context,
          length: 6,
          controller: otpController,
          keyboardType: TextInputType.number,
          textStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            activeColor: Colors.blueAccent,
            inactiveColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            selectedColor: Colors.blueAccent,
            fieldHeight: 50,
            fieldWidth: 45,
          ),
          onChanged: (v) {},
        ),
        const SizedBox(height: 10),
        Text(
          _seconds > 0 ? "Resend in ${_seconds}s" : "Didn't receive code?",
          style: const TextStyle(color: Colors.grey),
        ),
        if (_seconds == 0)
          TextButton(onPressed: _startTimer, child: const Text("Resend OTP")),
        const SizedBox(height: 40),
        _animatedButton("VERIFY & CONTINUE", () {
          if (otpController.text == "123456") {
            setState(() => step = 3);
          } else {
            _showWarning("Invalid OTP", "Try default OTP: 123456");
          }
        }),
      ],
    );
  }

  Widget _buildPINForm(bool isDark) {
    return Column(
      key: const ValueKey(3),
      children: [
        Text(
          "Enter 8-Digit Transaction PIN",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 30),
        PinCodeTextField(
          appContext: context,
          length: 8,
          obscureText: true,
          controller: pinController,
          keyboardType: TextInputType.number,
          textStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.underline,
            activeColor: Colors.blueAccent,
            inactiveColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            selectedColor: Colors.blueAccent,
            fieldHeight: 50,
            fieldWidth: 30,
          ),
          onChanged: (v) {},
        ),
        const SizedBox(height: 40),
        _animatedButton("CONFIRM PAYMENT", () {
          if (pinController.text == "12105007") {
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
          Lottie.network(
            "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Tick%20Market.json",
            height: 250,
            repeat: false,
          ),
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

  Widget _inputLabel(String label, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
    ),
  );

  InputDecoration _inputDecoration(
    String hint,
    IconData? icon,
    Color bgColor,
    bool isDark,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: icon != null
          ? Icon(icon, color: Colors.blueAccent, size: 20)
          : null,
      filled: true,
      fillColor: bgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.transparent : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
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
          elevation: 0,
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
    if (!mounted) return;
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

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(' ', '');
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length)
        buffer.write(' ');
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
