import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../services/payment_service.dart';
import '../widgets/animated_assets.dart';
import 'login_screen.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartController cartController = Get.find<CartController>();
  final AuthController authController = Get.find<AuthController>();

  final String loadingLottie =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/loading.json";
  final String emptyCartLottie =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/empty.json";
  final String deleteBinLottie =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Delete%20Bin.json";
  final String imageLoadingLottie =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/image%20viewer%20icon%20animation.json";
  final String cleanAllLottie =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/cleanAll.json";
  final String cartLockLottie =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/cartLocked.json";
  final String pullRefreshLottie =
      "https://assets10.lottiefiles.com/packages/lf20_usmfx6bp.json";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black87);
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "My Cart",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: textColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Obx(() {
          if (!authController.isLoggedIn.value) {
            return AnimatedAssets.pageEntrance(
              child: _buildLoginRequiredState(
                context,
                cardColor,
                textColor,
                subtitleColor!,
              ),
            );
          }

          if (cartController.isLoading.value &&
              cartController.cartItems.isEmpty) {
            return Center(
              child: Lottie.network(loadingLottie, height: 150, repeat: true),
            );
          }

          if (cartController.cartItems.isEmpty) {
            return _buildEmptyState(context, textColor, subtitleColor!);
          }

          final paidItems = cartController.cartItems
              .where(
                (i) =>
                    i['products'] != null &&
                    i['products']['is_donation'] == false,
              )
              .toList();
          final freeItems = cartController.cartItems
              .where(
                (i) =>
                    i['products'] != null &&
                    i['products']['is_donation'] == true,
              )
              .toList();
          double subtotal = paidItems.fold(
            0,
            (sum, item) => sum + (item['products']['price'] ?? 0).toDouble(),
          );

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: () => cartController.fetchCart(),
                      builder:
                          (
                            context,
                            refreshState,
                            pulledExtent,
                            refreshTriggerPullDistance,
                            refreshIndicatorExtent,
                          ) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Lottie.network(
                                  pullRefreshLottie,
                                  height: 70,
                                  animate:
                                      refreshState ==
                                          RefreshIndicatorMode.refresh ||
                                      refreshState ==
                                          RefreshIndicatorMode.armed,
                                ),
                              ),
                            );
                          },
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _sectionHeader(
                            context,
                            "🛒 Paid Items",
                            paidItems,
                            textColor,
                          ),
                          if (paidItems.isEmpty)
                            _emptySectionText(subtitleColor!)
                          else
                            ...paidItems.asMap().entries.map(
                              (e) => AnimatedAssets.animatedListItem(
                                delay: e.key * 80,
                                child: _buildCartTile(
                                  context,
                                  e.value,
                                  cardColor,
                                  textColor,
                                  subtitleColor!,
                                ),
                              ),
                            ),

                          const SizedBox(height: 25),

                          _sectionHeader(
                            context,
                            "🎁 Free / Donations",
                            freeItems,
                            textColor,
                          ),
                          if (freeItems.isEmpty)
                            _emptySectionText(subtitleColor!)
                          else
                            ...freeItems.asMap().entries.map(
                              (e) => AnimatedAssets.animatedListItem(
                                delay: e.key * 80,
                                child: _buildCartTile(
                                  context,
                                  e.value,
                                  cardColor,
                                  textColor,
                                  subtitleColor!,
                                ),
                              ),
                            ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCheckoutBar(
                context,
                subtotal,
                cardColor,
                textColor,
                subtitleColor,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCartTile(
    BuildContext context,
    dynamic item,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final product = item['products'];
    if (product == null) return const SizedBox.shrink();
    final List images = product['images'] ?? [];
    final String imageUrl = images.isNotEmpty ? images[0] : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: Lottie.network(imageLoadingLottie, repeat: true),
                    );
                  },
                )
              : Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
        ),
        title: Text(
          product['title'] ?? 'Unknown Product',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            product['is_donation'] == true ? "FREE" : "৳${product['price']}",
            style: TextStyle(
              color: product['is_donation'] == true
                  ? Colors.green
                  : Colors.blueAccent,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        trailing: GestureDetector(
          onTap: () => _confirmRemove(context, item['id']),
          child: Lottie.network(
            deleteBinLottie,
            height: 45,
            width: 45,
            repeat: true,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(
    BuildContext context,
    double subtotal,
    Color cardColor,
    Color textColor,
    Color? subtitleColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Subtotal:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: subtitleColor,
                ),
              ),
              Text(
                "৳${subtotal.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          AnimatedAssets.tapEffect(
            onTap: subtotal > 0
                ? () => PaymentService.showOrderSummary(
                    context,
                    subtotal,
                    cardColor,
                    textColor,
                    subtitleColor!,
                  )
                : () {},
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                gradient: subtotal > 0
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF0052D4),
                          Color(0xFF4364F7),
                          Color(0xFF6FB1FC),
                        ],
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade600, Colors.grey.shade500],
                      ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Secure Checkout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title,
    List items,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          if (items.isNotEmpty)
            GestureDetector(
              onTap: () => _handleRemoveAll(context, items),
              child: Row(
                children: [
                  Lottie.network(cleanAllLottie, height: 35, repeat: true),
                  const SizedBox(width: 5),
                  const Text(
                    "Clear All",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, dynamic cartId) {
    Get.defaultDialog(
      title: "Remove Item?",
      middleText: "Are you sure you want to remove this item?",
      textCancel: "Cancel",
      textConfirm: "Remove",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        cartController.deleteItem(cartId);
        Get.back();
      },
    );
  }

  void _handleRemoveAll(BuildContext context, List items) {
    Get.defaultDialog(
      title: "Clear Section?",
      middleText: "This will remove all items from this category.",
      textCancel: "Cancel",
      textConfirm: "Clear All",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        final ids = items.map((i) => i['id']).toList();
        cartController.removeAllItems(ids);
        Get.back();
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color textColor,
    Color subtitleColor,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () => cartController.fetchCart(),
        ),
        SliverFillRemaining(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(emptyCartLottie, height: 250, repeat: true),
              const SizedBox(height: 20),
              Text(
                "Your cart is feeling a bit light",
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Explore our items and add them here!",
                style: TextStyle(color: subtitleColor, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginRequiredState(
    BuildContext context,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            cartLockLottie,
            height: 200,
            width: 200,
            repeat: true,
            frameRate: FrameRate.max,
          ),
          const SizedBox(height: 24),
          Text(
            "Cart is Locked",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
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

  Widget _emptySectionText(Color subtitleColor) => Center(
    child: Text(
      "No items in this section",
      style: TextStyle(color: subtitleColor, fontSize: 13),
    ),
  );
}
