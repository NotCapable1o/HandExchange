import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/toast.dart';

class ProductRatingWidget extends StatefulWidget {
  final String productId;
  const ProductRatingWidget({super.key, required this.productId});

  @override
  State<ProductRatingWidget> createState() => _ProductRatingWidgetState();
}

class _ProductRatingWidgetState extends State<ProductRatingWidget> {
  final supabase = Supabase.instance.client;
  int userRating = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await supabase.from('ratings').select('rating_value').match({
        'user_id': userId,
        'product_id': widget.productId,
      }).maybeSingle();

      if (mounted && data != null) {
        setState(() {
          userRating = (data['rating_value'] as num).toInt();
        });
      }
    } catch (e) {
      debugPrint("Error loading rating: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _submitRating(int rating) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    int previousRating = userRating;

    try {
      if (userRating == rating) {
        setState(() => userRating = 0);
        await supabase.from('ratings').delete().match({
          'user_id': userId,
          'product_id': widget.productId,
        });
        showToast("Rating removed");
      } else {
        setState(() => userRating = rating);
        await supabase.from('ratings').upsert({
          'user_id': userId,
          'product_id': widget.productId,
          'rating_value': rating,
        }, onConflict: 'user_id, product_id');
        showToast("Rating saved!");
      }
    } catch (e) {
      setState(() => userRating = previousRating);
      showToast("Failed to update rating", success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox.shrink();

    return Row(
      children: [
        const Text("Rating: ", style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => _submitRating(index + 1),
              child: Icon(
                index < userRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 28,
              ),
            );
          }),
        ),
        if (userRating > 0)
          Text(" ($userRating/5)", style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
