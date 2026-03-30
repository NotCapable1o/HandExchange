import 'package:HandExchange/views/product_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../widgets/animated_assets.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController auth = Get.find<AuthController>();
  final ProductController productController = Get.find<ProductController>();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = auth.supabase.auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: Lottie.network(
                  "https://raw.githubusercontent.com/NotCapable1o/lottie/main/avatars%20multiple.json",
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Guest User",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Log in to manage your listings and profile.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => const LoginScreen()),
                  icon: const Icon(Icons.login, color: Colors.greenAccent),
                  label: const Text(
                    "Login / Register",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    String joinDate = "New";
    if (user.createdAt.isNotEmpty) {
      try {
        joinDate = DateFormat(
          'MMM yyyy',
        ).format(DateTime.parse(user.createdAt));
      } catch (e) {
        joinDate = "Recent";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _handleLogout(),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      body: AnimatedAssets.pageEntrance(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async => await productController.fetchProducts(),
              builder:
                  (
                    context,
                    refreshState,
                    pulledExtent,
                    refreshTriggerPullDistance,
                    refreshIndicatorExtent,
                  ) {
                    return Center(
                      child: AnimatedAssets.refreshAnimation(
                        height: pulledExtent.clamp(0.0, 100.0),
                      ),
                    );
                  },
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  Center(
                    child: Stack(
                      children: [
                        Obx(() {
                          final avatarUrl =
                              auth.user.value?.userMetadata?['avatar_url'];
                          return AnimatedAssets.glowingAvatar(
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.blueGrey[100],
                              child: ClipOval(
                                child: avatarUrl != null
                                    ? Image.network(
                                        avatarUrl,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,

                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child: SizedBox(
                                                  width: 45,
                                                  height: 45,
                                                  child: Lottie.network(
                                                    AnimatedAssets.refreshUrl,
                                                  ),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  size: 55,
                                                  color: Colors.white,
                                                ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 55,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          );
                        }),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => auth.updateAvatar(),
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 18,
                              child: const Icon(
                                Icons.add_a_photo,
                                size: 16,
                                color: Colors.cyanAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Obx(
                    () => Text(
                      auth.userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    user.email ?? "",
                    style: TextStyle(color: Colors.yellow[600], fontSize: 14),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    child: AnimatedAssets.tapEffect(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStat("Joined", joinDate),
                            _buildStat("Status", "Seller"),
                            Obx(() {
                              final count = productController.products
                                  .where((p) => p['user_id'] == user.id)
                                  .length;
                              return _buildStat("Listings", count.toString());
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Divider(thickness: 1, indent: 20, endIndent: 20),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "My Active Listings",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Obx(() {
              final myProducts = productController.products
                  .where((p) => p['user_id'] == user.id)
                  .toList();

              if (myProducts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: AnimatedAssets.emptyListings(),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = myProducts[index];
                  final images = item['images'] as List?;
                  final imageUrl = (images != null && images.isNotEmpty)
                      ? images[0]
                      : null;

                  return AnimatedAssets.animatedListItem(
                    delay: index * 100,
                    child: ListTile(
                      onTap: () =>
                          Get.to(() => ProductDetailsScreen(product: item)),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[200],
                                width: 55,
                                height: 55,
                                child: const Icon(Icons.image),
                              ),
                      ),
                      title: Text(
                        item['title'] ?? "No Title",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "৳${item['price']}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _confirmDelete(item['id'].toString()),
                      ),
                    ),
                  );
                }, childCount: myProducts.length),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        label == "Listings"
            ? AnimatedAssets.animatedCounter(value: int.tryParse(value) ?? 0)
            : Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  void _handleLogout() {
    Get.defaultDialog(
      title: "Confirm Logout",
      middleText: "Are you sure you want to sign out?",
      textConfirm: "Logout",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.yellow,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        auth.logout();
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  void _confirmDelete(String productId) {
    Get.defaultDialog(
      title: "Delete Listing?",
      middleText: "This action cannot be undone.",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.black,
      buttonColor: Colors.redAccent,
      onConfirm: () async {
        Get.back();
        await productController.deleteProduct(productId);
      },
      onCancel: () => Get.back(),
    );
  }
}
