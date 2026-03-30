import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/auth_controller.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController authController = Get.find<AuthController>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _confirmPassFocusNode = FocusNode();

  final double mainAssetHeight = 240.0;
  final double mainAssetWidth = 240.0;
  final double iconSize = 28.0;

  final String urlLogin =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Login/loginActivity.json";
  final String urlEyeOff =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Login/eyeOff.json";
  final String urlIconOn =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Login/eyeIconOn.json";

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _passFocusNode.addListener(() => setState(() {}));
    _confirmPassFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passFocusNode.dispose();
    _confirmPassFocusNode.dispose();
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


  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      bool success = await authController.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text("Verify Your Email"),
              content: const Text(
                "Check your email inbox to verify your account before logging in.",
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.off(() => const LoginScreen());
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    bool showEyeOff =
        (_passFocusNode.hasFocus && !_isPasswordVisible) ||
        (_confirmPassFocusNode.hasFocus && !_isConfirmPasswordVisible);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,

            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Lottie.network(
                  showEyeOff ? urlEyeOff : urlLogin,
                  height: mainAssetHeight,
                  width: mainAssetWidth,
                  repeat: !showEyeOff,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 0),

                const Text(
                  "Join HandExchange",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Student-to-student marketplace",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 25),

                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? "Please enter your name"
                      : null,
                ),
                const SizedBox(height: 15),


                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      GetUtils.isEmail(v ?? "") ? null : "Enter a valid email",
                ),
                const SizedBox(height: 15),

                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _passwordController,
                  focusNode: _passFocusNode,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    helperText: "8+ chars, ABC, abc, 123, @",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: _isPasswordVisible
                          ? SizedBox(
                              width: iconSize,
                              child: Lottie.network(urlIconOn, repeat: true),
                            )
                          : const Icon(Icons.visibility_off_outlined),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  textInputAction: TextInputAction.done,
                  controller: _confirmPasswordController,
                  focusNode: _confirmPassFocusNode,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: _isConfirmPasswordVisible
                          ? SizedBox(
                              width: iconSize,
                              child: Lottie.network(urlIconOn, repeat: true),
                            )
                          : const Icon(Icons.visibility_off_outlined),
                      onPressed: () => setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please confirm password";
                    }
                    if (value != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                Obx(
                  () => authController.isLoading.value
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
                            ),
                            onPressed: _handleSignup,
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () => Get.off(() => const LoginScreen()),
                      child: const Text("Login"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
