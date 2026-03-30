import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

import '../views/internet_check_screen.dart';
import '../views/login_screen.dart';
import '../views/main_wrapper.dart';
import '../views/reset_password_screen.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final _appLinks = AppLinks();

  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  Rxn<User> user = Rxn<User>();
  bool _isRecovering = false;

  bool get isAuthenticated => supabase.auth.currentSession != null;

  String get userName {
    final u = user.value ?? supabase.auth.currentUser;
    if (u != null && u.userMetadata != null) {
      return u.userMetadata!['full_name'] ?? "User";
    }
    return "User";
  }

  String? get userId => user.value?.id ?? supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    user.value = supabase.auth.currentUser;
    isLoggedIn.value = isAuthenticated;
    _initDeepLinks();
    _initSupabaseListener();
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.contains(ConnectivityResult.none)) {
        if (Get.currentRoute != '/NoInternetScreen') {
          Get.to(() => const NoInternetScreen(), transition: Transition.fadeIn);
        }
      } else {
        if (Get.currentRoute == '/NoInternetScreen') {
          Get.back();
        }
      }
    });
  }

  void _initDeepLinks() {
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleLink(uri);
    });

    _appLinks.uriLinkStream.listen(
      (uri) {
        _handleLink(uri);
      },
      onError: (err) {
        debugPrint("🔗 Link Stream Error: $err");
      },
    );
  }

  void _handleLink(Uri uri) {
    if (uri.toString().contains('reset-password')) {
      _isRecovering = true;
      Get.offAll(() => const ResetPasswordScreen());
    }
  }

  void _initSupabaseListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      user.value = session?.user;
      isLoggedIn.value = session != null;

      print("AUTH EVENT: $event");

      if (event == AuthChangeEvent.passwordRecovery) {
        _isRecovering = true;

        if (Get.currentRoute != "/ResetPasswordScreen") {
          Get.offAll(() => const ResetPasswordScreen());
        }
        return;
      }

      if (event == AuthChangeEvent.signedIn) {
        if (_isRecovering) return;

        if (Get.currentRoute != "/MainWrapper") {
          Get.offAll(() => MainWrapper());
        }
        return;
      }

      if (event == AuthChangeEvent.signedOut) {
        _isRecovering = false;

        if (Get.currentRoute != "/LoginScreen") {
          Get.offAll(() => const LoginScreen());
        }
        return;
      }
    });
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      isLoading.value = true;

      final res = await supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {'full_name': name},
      );

      if (res.user != null) {
        return true;
      }

      return false;
    } on AuthException catch (e) {
      _showError("Signup Failed", e.message);
      return false;
    } catch (e) {
      _showError("Error", "An unexpected error occurred.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      isLoading.value = true;

      await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Something went wrong.";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      await supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'handexchange://reset-password',
      );
      _showSuccess("Check Email", "Password reset link sent.");
    } catch (e) {
      _showError("Reset Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateNewPassword(String newPassword) async {
    try {
      isLoading.value = true;
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword.trim()),
      );
      _isRecovering = false;
      await signOut();
      _showSuccess("Success", "Password updated! Please login.");
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      _showError("Update Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void logout() => signOut();
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> updateAvatar() async {
    if (!isAuthenticated) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image == null) return;

    try {
      isLoading.value = true;
      final file = File(image.path);
      final String uid = supabase.auth.currentUser!.id;
      final fileName = '$uid/avatar.jpg';

      await supabase.storage
          .from('avatars')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final String publicUrl =
          "${supabase.storage.from('avatars').getPublicUrl(fileName)}?t=${DateTime.now().millisecondsSinceEpoch}";

      final userResponse = await supabase.auth.updateUser(
        UserAttributes(data: {'avatar_url': publicUrl}),
      );
      await supabase
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', uid);

      if (userResponse.user != null) user.value = userResponse.user;
      _showSuccess("Success", "Avatar updated!");
    } catch (e) {
      _showError("Upload failed", "Could not upload image.");
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String title, String message) {
    if (!Get.isSnackbarOpen) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.context != null) {
          Get.snackbar(
            title,
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            margin: const EdgeInsets.all(15),
            borderRadius: 12,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.error_outline, color: Colors.white),
          );
        }
      });
    }
  }

  void _showSuccess(String title, String message) {
    if (!Get.isSnackbarOpen) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.context != null) {
          Get.snackbar(
            title,
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: const EdgeInsets.all(15),
            borderRadius: 12,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          );
        }
      });
    }
  }
}
