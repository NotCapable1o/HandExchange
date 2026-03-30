import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/product_controller.dart';
import '../../views/product_details_screen.dart';

class HomeBannerCarousel extends StatelessWidget {
  final ProductController controller;

  const HomeBannerCarousel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final latestProducts = controller.products.take(5).toList();
      if (latestProducts.isEmpty) return const SizedBox.shrink();

      return CarouselSlider(
        options: CarouselOptions(
          height: 210.0,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.88,
          autoPlayInterval: const Duration(seconds: 5),
        ),
        items: latestProducts.map((product) {
          final imageUrl =
              (product['images'] != null && product['images'].isNotEmpty)
              ? product['images'][0]
              : 'https://via.placeholder.com/600x300';

          return GestureDetector(
            onTap: () => Get.to(() => ProductDetailsScreen(product: product)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;

                          return Center(
                            child: Lottie.network(
                              'https://raw.githubusercontent.com/NotCapable1o/lottie/main/HomeScreen/sliderImageLoader.json',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 15,
                      left: 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['title'] ?? "No Title",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.yellowAccent.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product['is_donation'] == true
                                  ? "FREE"
                                  : "৳${product['price']}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
