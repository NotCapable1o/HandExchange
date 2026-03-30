import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductSellerCard extends StatefulWidget {
  final Map? profiles;
  final bool isOwner;

  const ProductSellerCard({
    super.key,
    required this.profiles,
    required this.isOwner,
  });

  @override
  State<ProductSellerCard> createState() => _ProductSellerCardState();
}

class _ProductSellerCardState extends State<ProductSellerCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String name = widget.profiles?['full_name'] ?? "HandExchange Student";
    final String avatar = widget.profiles?['avatar_url'] ?? "";

    final String joinDate = widget.profiles?['created_at'] != null
        ? DateFormat.yMMMd().format(
            DateTime.parse(widget.profiles!['created_at']),
          )
        : "Recent";

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => isExpanded = !isExpanded);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isOwner
              ? Colors.green.withOpacity(0.05)
              : Colors.blueAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (widget.isOwner ? Colors.green : Colors.blueAccent)
                .withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildAvatar(avatar),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            color: Colors.blueAccent,
                            size: 18,
                          ),
                        ],
                      ),
                      const Text(
                        "Verified Student @ BRUR",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.blueAccent,
                ),
              ],
            ),

            if (isExpanded) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(thickness: 0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _sellerStat(
                    "4.9",
                    "Rating",
                    Icons.star_rounded,
                    Colors.orange,
                  ),
                  _sellerStat(
                    joinDate,
                    "Joined",
                    Icons.calendar_month_rounded,
                    Colors.blue,
                  ),

                  _sellerStat(
                    "Verified",
                    "Trust",
                    Icons.security_rounded,
                    Colors.green,
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                // child: const Center(
                //   child: Text("View Student Profile",
                //       style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                // ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildAvatar(String url) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.blueAccent.withOpacity(0.1),
        backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
        child: url.isEmpty
            ? const Icon(Icons.person, color: Colors.blueAccent)
            : null,
      ),
    );
  }

  Widget _sellerStat(String val, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          val,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
