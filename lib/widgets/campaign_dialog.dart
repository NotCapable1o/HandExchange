import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:get/get.dart'
    hide GetNumUtils, ContextExtensionsNum, NumDurationExtensions;
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../views/product_details_screen.dart';

class CampaignDialog {
  static void show(BuildContext context, Map product) {
    final String imageUrl =
        (product['images'] != null && (product['images'] as List).isNotEmpty)
        ? product['images'][0]
        : 'https://via.placeholder.com/600x400';

    final String price = "${product['price'] ?? '0'} ৳";
    final Size screenSize = MediaQuery.of(context).size;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.elasticOut.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: Center(
              child: SingleChildScrollView(
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: screenSize.width * 0.85,

                        height: (screenSize.height * 0.6).clamp(350.0, 480.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Glass Footer
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: _buildGlassFooter(context, product),
                              ),
                              // Price Tag
                              Positioned(
                                top: 20,
                                left: 20,
                                child: _buildPriceTag(price),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        top: -50,
                        child: IgnorePointer(
                          child: Lottie.network(
                            'https://assets10.lottiefiles.com/packages/lf20_u4yrau.json',
                            width: screenSize.width * 0.9,
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildPriceTag(String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 219, 127, 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        price,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds);
  }

  static Widget _buildGlassFooter(BuildContext context, Map product) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white.withOpacity(0.1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (product['title'] ?? "Limited Offer").toString().toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(1, 47, 47, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(() => ProductDetailsScreen(product: product));
                    },
                    child: const Text(
                      "GRAB IT NOW",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.limeAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.03, 1.03),
                    duration: 0.5.seconds,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
