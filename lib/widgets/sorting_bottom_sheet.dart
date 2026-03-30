import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../utils/theme.dart';

class SortingBottomSheet extends StatelessWidget {
  const SortingBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sort & Filter",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => controller.resetFilters(),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        "Reset",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  "Price Range",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppThemes.primaryBlue,
                    inactiveTrackColor: AppThemes.primaryBlue.withOpacity(0.1),
                    thumbColor: AppThemes.primaryBlue,
                    overlayColor: AppThemes.primaryBlue.withOpacity(0.2),
                    rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 10,
                      elevation: 5,
                    ),
                    trackHeight: 6,
                    valueIndicatorColor: AppThemes.primaryBlue,
                    valueIndicatorTextStyle: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  child: RangeSlider(
                    values: RangeValues(
                      controller.minPrice.value,
                      controller.maxPrice.value,
                    ),
                    min: 0,
                    max: 100000,
                    divisions: 200,
                    labels: RangeLabels(
                      "৳${(controller.minPrice.value / 1000).toStringAsFixed(1)}k",
                      "৳${(controller.maxPrice.value / 1000).toStringAsFixed(1)}k",
                    ),
                    onChanged: (values) {
                      controller.minPrice.value = values.start;
                      controller.maxPrice.value = values.end;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "৳${controller.minPrice.value.round()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "৳${controller.maxPrice.value.round()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppThemes.primaryBlue,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Sort By",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildSortChip(
                      controller,
                      "A - Z",
                      'alpha',
                      Icons.sort_by_alpha,
                    ),
                    _buildSortChip(
                      controller,
                      "Price ↓",
                      'low',
                      Icons.trending_down,
                    ),
                    _buildSortChip(
                      controller,
                      "Price ↑",
                      'high',
                      Icons.trending_up,
                    ),
                    _buildSortChip(
                      controller,
                      "Free",
                      'free',
                      Icons.volunteer_activism,
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _applySort(controller, controller.activeSort.value);
                      Get.back();
                    },
                    child: const Text(
                      "Apply Selection",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(
    ProductController controller,
    String label,
    String criteria,
    IconData icon,
  ) {
    bool isSelected = controller.activeSort.value == criteria;
    return GestureDetector(
      onTap: () {
        controller.activeSort.value = criteria;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemes.primaryBlue
              : (Get.isDarkMode
                    ? Colors.white10
                    : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppThemes.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (Get.isDarkMode ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applySort(ProductController controller, String criteria) {
    controller.activeSort.value = criteria;

    List<Map<String, dynamic>> items;
    if (controller.selectedCategory.value == "All") {
      items = List<Map<String, dynamic>>.from(controller.products);
    } else {
      items = List<Map<String, dynamic>>.from(
        controller.products.where(
          (p) => p['category'] == controller.selectedCategory.value,
        ),
      );
    }

    items = items.where((p) {
      final double pPrice = (p['price'] ?? 0).toDouble();
      return pPrice >= controller.minPrice.value &&
          pPrice <= controller.maxPrice.value;
    }).toList();

    switch (criteria) {
      case 'alpha':
        items.sort(
          (a, b) => (a['title'] ?? '').toString().toLowerCase().compareTo(
            (b['title'] ?? '').toString().toLowerCase(),
          ),
        );
        break;
      case 'low':
        items.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
        break;
      case 'high':
        items.sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
        break;
      case 'free':
        items = items.where((p) => p['is_donation'] == true).toList();
        break;
    }

    controller.filteredProducts.assignAll(items);
  }
}
