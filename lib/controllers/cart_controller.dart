import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartController extends GetxController {
  final supabase = Supabase.instance.client;

  final cartItems = <dynamic>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      cartItems.clear();
      return;
    }

    try {
      isLoading(true);
      final data = await supabase
          .from('cart')
          .select('*, products(*)')
          .eq('user_id', user.id);

      cartItems.assignAll(data);
    } catch (e) {
      debugPrint("Fetch Cart Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> addToCart(String productId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      _showFeedback(
        "Action Required",
        "Please login to add items",
        isError: true,
      );
      return;
    }

    try {
      await supabase.from('cart').insert({
        'user_id': userId,
        'product_id': productId,
      });

      await fetchCart();
      _showFeedback("Success", "Item added to cart");
    } catch (e) {
      _showFeedback("Notice", "Item already exists in cart", isError: true);
    }
  }

  Future<void> deleteItem(dynamic cartId) async {
    try {
      cartItems.removeWhere((item) => item['id'] == cartId);

      await supabase.from('cart').delete().eq('id', cartId);

      _showFeedback("Removed", "Item removed from cart");
    } catch (e) {
      await fetchCart();
      _showFeedback("Error", "Failed to remove item", isError: true);
    }
  }

  Future<void> removeAllItems(List<dynamic> ids) async {
    try {
      isLoading(true);

      final List<Object> safeIds = ids.cast<Object>();

      await supabase.from('cart').delete().inFilter('id', safeIds);

      await fetchCart();
      _showFeedback("Cleared", "Items successfully removed");
    } catch (e) {
      debugPrint("Remove All Items Error: $e");
      _showFeedback("Error", "Failed to remove items", isError: true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> clearCart() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      isLoading(true);

      await supabase.from('cart').delete().eq('user_id', userId);

      cartItems.clear();
      _showFeedback("Success", "Order placed successfully!");
    } catch (e) {
      debugPrint("Clear Cart Error: $e");
      _showFeedback("Error", "Error clearing cart", isError: true);
    } finally {
      isLoading(false);
    }
  }

  void _showFeedback(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }
}
