import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../services/notification_service.dart';
import '../widgets/animated_assets.dart';
import '../widgets/campaign_dialog.dart';
import '../widgets/home/category_selector.dart';
import '../widgets/home/home_banner_carousel.dart';
import '../widgets/home/product_card.dart';
import '../widgets/home/section_header.dart';
import '../widgets/product_search_delegate.dart';
import 'developer_info.dart';
import 'notification_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductController productController = Get.find<ProductController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && productController.products.isNotEmpty) {
        final allProducts = List.from(productController.products);
        allProducts.shuffle();
        final randomProduct = allProducts.first;
        CampaignDialog.show(context, randomProduct);
      }
    });

    bool notificationSent = false;

    ever(productController.products, (_) {
      if (!notificationSent && productController.products.isNotEmpty) {
        notificationSent = true;

        final randomProduct = (List.from(
          productController.products,
        )..shuffle()).first;

        NotificationService.showRandomProductNotification(randomProduct);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onTap: () => Get.to(() => const DeveloperInfo()),
          child: const Text(
            "HandExchange",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
          onPressed: () => Get.to(() => const FavoritesScreen()),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              showSearch(context: context, delegate: ProductSearchDelegate());
            },
          ),

          Obx(
            () => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () {
                    NotificationService.notificationCount.value = 0;
                    Get.to(() => const NotificationScreen());
                  },
                ),
                if (NotificationService.notificationCount.value > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${NotificationService.notificationCount.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () =>
                Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
          ),
        ],
      ),
      body: CustomScrollView(
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
                const SizedBox(height: 10),

                HomeBannerCarousel(controller: productController),

                CategorySelector(controller: productController),

                const SectionHeader(title: "Available Products"),
              ],
            ),
          ),

          Obx(() {
            if (productController.isLoading.value &&
                productController.products.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (productController.filteredProducts.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text("No items found.")),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = productController.filteredProducts[index];

                  return AnimatedAssets.animatedListItem(
                    delay: index * 50,
                    child: ProductCard(item: item),
                  );
                }, childCount: productController.filteredProducts.length),
              ),
            );
          }),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
