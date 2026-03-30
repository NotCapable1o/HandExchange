import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final FocusNode _passFocus = FocusNode();
  final FocusNode _confirmPassFocus = FocusNode();

  final double mainAssetH = 260.0;
  final double mainAssetW = 260.0;
  final double iconSize = 28.0;

  final String urlLogin =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Login/loginActivity.json";
  final String urlEyeOff =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Login/eyeOff.json";
  final String urlIconOn =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Login/eyeIconOn.json";

  bool _isPassHidden = true;
  bool _isConfirmHidden = true;

  @override
  void initState() {
    super.initState();

    _passFocus.addListener(() => setState(() {}));
    _confirmPassFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    _passFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 8) return "Must be at least 8 characters";
    final passwordRegExp = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
    );
    if (!passwordRegExp.hasMatch(value)) return "Need: ABC, abc, 123, & @";
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final AuthController auth = Get.find<AuthController>();
      auth.updateNewPassword(_passController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    bool reallyHiding =
        (_passFocus.hasFocus && _isPassHidden) ||
        (_confirmPassFocus.hasFocus && _isConfirmHidden);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Reset Your Password"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: mainAssetH,
                    width: mainAssetW,
                    child: Lottie.network(
                      reallyHiding ? urlEyeOff : urlLogin,
                      repeat: !reallyHiding,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Text(
                    "Create New Password",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Set a strong password to protect your account.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 30),

                  TextFormField(
                    controller: _passController,
                    focusNode: _passFocus,
                    obscureText: _isPassHidden,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: "New Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: _isPassHidden
                            ? const Icon(Icons.visibility_off_outlined)
                            : SizedBox(
                                width: iconSize,
                                child: Lottie.network(urlIconOn),
                              ),
                        onPressed: () =>
                            setState(() => _isPassHidden = !_isPassHidden),
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 20),

                  // --- CONFIRM PASSWORD FIELD ---
                  // --- CONFIRM PASSWORD FIELD ---
                  TextFormField(
                    controller: _confirmPassController,
                    focusNode: _confirmPassFocus,
                    obscureText: _isConfirmHidden,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: "Confirm New Password",
                      prefixIcon: const Icon(Icons.lock_reset),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: _isConfirmHidden
                            ? const Icon(Icons.visibility_off_outlined)
                            : SizedBox(
                                width: iconSize,
                                child: Lottie.network(urlIconOn),
                              ),
                        onPressed: () => setState(
                          () => _isConfirmHidden = !_isConfirmHidden,
                        ),
                      ),
                    ),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != _passController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 35),

                  GetX<AuthController>(
                    builder: (auth) => auth.isLoading.value
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: _handleSubmit,
                              child: const Text(
                                "Update Password",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
