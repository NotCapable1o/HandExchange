import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'product_details_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  final SupabaseClient supabase = Supabase.instance.client;
  final AuthController authController = Get.find<AuthController>();
  final ProductController productController = Get.find<ProductController>();

  final String emptyNotification =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Notification/notBlock.json";

  final String notificationDrawer =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Notification/notificationDrawer.json";

  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (authController.isLoggedIn.value) {
      _fetchNotifications();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && authController.isLoggedIn.value) {
      _fetchNotifications();
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _notifications = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAllNotifications() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      await supabase.from('notifications').delete().eq('user_id', userId);

      _fetchNotifications();
      Get.snackbar(
        "Cleared",
        "All notifications removed",
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Check if 'product_id' column exists in Supabase",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _clearAllNotifications,
                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                label: const Text(
                  "Clear All",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Obx(
        () => authController.isLoggedIn.value
            ? FloatingActionButton.extended(
                onPressed: _simulateNotification,
                label: const Text("Simulate Alert"),
                icon: const Icon(Icons.bolt),
                backgroundColor: Colors.blueAccent,
              )
            : const SizedBox.shrink(),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;

    if (!authController.isLoggedIn.value) {
      return _buildLockedState(context, textColor);
    }

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_notifications.isEmpty) return _buildEmptyState(isDark);

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return _buildNotificationCard(item, isDark);
        },
      ),
    );
  }

  Widget _buildNotificationCard(dynamic item, bool isDark) {
    return InkWell(
      onTap: () => _handleItemClick(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.notifications, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? "Update",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    item['body'] ?? "",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatDate(item['created_at']),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  void _handleItemClick(dynamic item) {
    if (item['product_id'] != null) {
      final product = productController.products.firstWhere(
        (p) => p['id'].toString() == item['product_id'].toString(),
        orElse: () => null,
      );
      if (product != null) {
        Get.to(() => ProductDetailsScreen(product: product));
      } else {
        Get.snackbar("Notice", "Product details not found.");
      }
    }
  }

  Future<void> _simulateNotification() async {
    if (productController.products.isEmpty) {
      Get.snackbar("Wait", "Products are still loading...");
      return;
    }

    final randomProduct = (List.from(
      productController.products,
    )..shuffle()).first;
    final String name = randomProduct['title'] ?? "New Item";
    final String id = randomProduct['id'].toString();

    try {
      NotificationService.showProductUpdateNotification(name, productId: id);

      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase.from('notifications').insert({
          'user_id': userId,
          'title': 'New Product Alert!',
          'body': 'Check out $name',
          'product_id': id,
        });
        _fetchNotifications();
      }
    } catch (e) {
      debugPrint("Simulation Error: $e");
      Get.snackbar(
        "SQL Error",
        "Did you add the 'product_id' column in Supabase?",
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      return DateFormat(
        'dd MMM, hh:mm a',
      ).format(DateTime.parse(dateStr).toLocal());
    } catch (_) {
      return "";
    }
  }

  Widget _buildLockedState(BuildContext context, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            emptyNotification,
            height: 220,
            width: 220,
            backgroundLoading: true,
          ),
          const SizedBox(height: 20),
          Text(
            "Notifications Locked",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Join us to stay updated with the latest products and community alerts.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const LoginScreen()),
            icon: const Icon(Icons.login, color: Colors.greenAccent),
            label: const Text(
              "Login / Register",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: ListView(
        children: [
          SizedBox(height: 100),
          Lottie.network(notificationDrawer, height: 200),
          Center(
            child: Text(
              "Check Notification Drawer",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
