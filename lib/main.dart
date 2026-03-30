import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/product_controller.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await Firebase.initializeApp();
    debugPrint("🔥 Firebase initialized successfully");
  } catch (e) {
    debugPrint("❌ Firebase initialization failed: $e");
  }

  await Supabase.initialize(
    url: 'https://omnafoglzcduwnjhissw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9tbmFmb2dsemNkdXduamhpc3N3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0MzA2MzYsImV4cCI6MjA4NjAwNjYzNn0.KJogCFkGZ6YrwEr1itl76I9CYxpMcN_kE5knSFKNSjI',
  );

  try {
    await NotificationService.initialize();
    await NotificationService.getToken();
  } catch (e) {
    debugPrint("❌ Notification initialization failed: $e");
  }

  Get.put(AuthController(), permanent: true);
  Get.put(ProductController(), permanent: true);
  Get.put<CartController>(CartController(), permanent: true);

  await GetStorage.init();

  runApp(HandExchangeApp());
}

class HandExchangeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();
    return GetMaterialApp(
      title: 'HandExchange',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,

      home: SplashScreen(),
    );
  }
}

///121 last
