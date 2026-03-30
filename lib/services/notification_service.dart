import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../views/product_details_screen.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static var notificationCount = 0.obs;

  static Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationClick(response.payload);
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  static Future<void> showRandomProductNotification(
    Map<String, dynamic> product,
  ) async {
    final String productName = product['title'] ?? "New Item";
    final String productId = product['id'].toString();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'product_updates_channel',
          'Product Updates',
          importance: Importance.max,
          priority: Priority.high,
        );

    List<String> templates = [
      "🔥 Hot Deal: $productName just landed!",
      "✨ Recommended: $productName",
      "Check out $productName near you!",
    ];

    String message = (templates..shuffle()).first;

    notificationCount.value++;

    await _localNotifications.show(
      id: product.hashCode,
      title: "HandExchange Update",
      body: message,
      notificationDetails: NotificationDetails(android: androidDetails),
      payload: productId,
    );

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        await Supabase.instance.client.from('notifications').insert({
          'user_id': user.id,
          'title': 'HandExchange Update',
          'body': message,
          'product_id': productId,
        });
      }
    } catch (e) {
      debugPrint("❌ Notification DB error: $e");
    }
  }

  static void _handleNotificationClick(String? productId) {
    if (productId != null) {
      final productController = Get.find<ProductController>();
      final product = productController.products.firstWhereOrNull(
        (p) => p['id'].toString() == productId,
      );

      if (product != null) {
        notificationCount.value = 0;
        Get.to(() => ProductDetailsScreen(product: product));
      }
    }
  }

  static void _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    notificationCount.value++;

    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> getToken() async {
    String? token = await _messaging.getToken();
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null && token != null) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({'fcm_token': token})
            .eq('id', user.id);
      } catch (e) {
        if (kDebugMode) print("❌ Failed to save token: $e");
      }
    }
  }

  static Future<void> showProductUpdateNotification(
    String name, {
    String? productId,
  }) async {
    await showRandomProductNotification({'title': name, 'id': productId});
  }
}
