import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gal/gal.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';

import '../../utils/toast.dart';

class ProductImageCarousel extends StatefulWidget {
  final List images;

  const ProductImageCarousel({super.key, required this.images});

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  int _currentIndex = 0;

  Future<void> _saveImage(String url) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final access = await Gal.requestAccess();
        if (!access) {
          showToast("Permission denied", success: false);
          return;
        }
      }
      showToast("Downloading...");
      var response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      await Gal.putImageBytes(
        Uint8List.fromList(response.data),
        name: "product_${DateTime.now().millisecondsSinceEpoch}",
      );
      showToast("Saved to Gallery");
    } catch (e) {
      showToast("Error saving image", success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 380,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 80, color: Colors.grey),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 380,
            viewportFraction: 1.0,
            autoPlay: widget.images.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.images
              .map(
                (url) => GestureDetector(
                  onLongPress: () {
                    HapticFeedback.mediumImpact();
                    Get.defaultDialog(
                      title: "Save Image",
                      middleText: "Save this image to gallery?",
                      textCancel: "Cancel",
                      textConfirm: "Save",
                      onConfirm: () {
                        Get.back();
                        _saveImage(url.toString());
                      },
                    );
                  },
                  child: Image.network(
                    url.toString(),
                    fit: BoxFit.cover,
                    width: double.infinity,

                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded || frame != null) {
                            return child;
                          }
                          return _buildLoader();
                        },

                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildLoader();
                    },
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),

        if (widget.images.length > 1)
          Positioned(
            bottom: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.images.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == entry.key ? 20.0 : 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(
                      _currentIndex == entry.key ? 0.9 : 0.4,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildLoader() {
    return Container(
      height: 380,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Lottie.network(
          'https://raw.githubusercontent.com/NotCapable1o/lottie/main/HomeScreen/sliderImageLoader.json',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
