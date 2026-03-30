import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ProductHeaderSection extends StatelessWidget {
  final Map product;
  final bool isLoadingInteractions;
  final bool isLiked;
  final bool isDisliked;
  final int likeCount;
  final Function(bool) onReactionPressed;

  const ProductHeaderSection({
    super.key,
    required this.product,
    required this.isLoadingInteractions,
    required this.isLiked,
    required this.isDisliked,
    required this.likeCount,
    required this.onReactionPressed,
  });

  void _shareProduct() {
    final String title = product['title'] ?? "Check out this item!";
    final String price = product['is_donation'] == true
        ? "Free"
        : "৳${product['price']}";

    const String downloadUrl =
        "https://drive.google.com/drive/folders/1Tv3X4zWY8CeogzA6Mrjz_j1f93yKQE23?usp=sharing";

    Share.share(
      "🔥 Check out this $title\n"
      "💰 Price: $price\n\n"
      "📦 Get the HandExchange app to see more details and contact the seller:\n"
      "$downloadUrl",
      subject: 'HandExchange: $title',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accentColor = isDark
        ? Colors.orangeAccent
        : const Color(0xFF0064FB);
    final Color cardColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.grey[50]!;

    final String condition = (product['condition'] ?? 'Used')
        .toString()
        .toUpperCase();
    final String priceText = product['is_donation'] == true
        ? "FREE"
        : "৳${product['price']}";

    final Random random = Random();

    final int randomHours = random.nextInt(23) + 1;

    final int randomViews = random.nextInt(500) + 50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildStatusBadge(
                  condition,
                  condition == "NEW" ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 8),
                if (product['is_negotiable'] ?? true)
                  _buildStatusBadge("NEGOTIABLE", Colors.purple),
              ],
            ),
            IconButton.filledTonal(
              onPressed: _shareProduct,
              icon: const Icon(Icons.share_outlined, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: accentColor.withOpacity(0.1),
                foregroundColor: accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          product['title'] ?? "Unknown Product",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              "$randomHours ${randomHours == 1 ? 'hour' : 'hours'} ago",
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(width: 15),
            Icon(
              Icons.remove_red_eye_outlined,
              size: 14,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 4),
            Text(
              "$randomViews Views",
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Price",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    priceText,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              _buildRatingInfo(product),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildReactionBtn(
                isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                "Helpful ($likeCount)",
                isLiked,
                Colors.blue,
                () => onReactionPressed(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReactionBtn(
                isDisliked ? Icons.report_rounded : Icons.report_outlined,
                "Report",
                isDisliked,
                Colors.redAccent,
                () => onReactionPressed(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRatingInfo(Map p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
            const SizedBox(width: 4),
            Text(
              "${p['calculated_avg'] ?? 0.0}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          "${p['calculated_count'] ?? 0} reviews",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildReactionBtn(
    IconData icon,
    String label,
    bool active,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: active ? color : Colors.grey.withOpacity(0.3),
          ),
          color: active ? color.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: active ? color : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
