import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/theme.dart';
import '../sorting_bottom_sheet.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            onPressed: () => Get.bottomSheet(const SortingBottomSheet()),
            icon: const Icon(Icons.filter_list_rounded, size: 18),
            label: const Text("Sort"),
            style: TextButton.styleFrom(foregroundColor: AppThemes.primaryBlue),
          ),
        ],
      ),
    );
  }
}
