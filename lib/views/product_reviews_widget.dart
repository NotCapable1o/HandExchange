import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/product_controller.dart';
import '../utils/toast.dart';

class ProductReviewsWidget extends StatefulWidget {
  final String productId;
  final VoidCallback onRefresh;

  const ProductReviewsWidget({
    super.key,
    required this.productId,
    required this.onRefresh,
  });

  @override
  State<ProductReviewsWidget> createState() => _ProductReviewsWidgetState();
}

class _ProductReviewsWidgetState extends State<ProductReviewsWidget> {
  final supabase = Supabase.instance.client;
  final TextEditingController _reviewController = TextEditingController();

  late Future<List<Map<String, dynamic>>> _reviewsFuture;
  bool _isSubmitting = false;
  bool _isEditing = false;
  String? _existingReviewId;
  int _charCount = 0;
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _checkAndPrepareReview();
    _reviewController.addListener(() {
      if (mounted) setState(() => _charCount = _reviewController.text.length);
    });
  }

  Future<void> _checkAndPrepareReview() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase.from('reviews').select().match({
      'product_id': widget.productId,
      'user_id': userId,
    }).maybeSingle();

    if (mounted && response != null) {
      setState(() {
        _isEditing = true;
        _existingReviewId = response['id'].toString();
        _reviewController.text = response['content'] ?? "";
        _selectedRating = response['rating'] ?? 5;
      });
    }
  }

  void _loadReviews() {
    setState(() {
      _reviewsFuture = supabase
          .from('reviews')
          .select('*, profiles(full_name, avatar_url)')
          .eq('product_id', widget.productId)
          .order('created_at', ascending: false);
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final userId = supabase.auth.currentUser?.id;
    final text = _reviewController.text.trim();

    if (userId == null || text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final Map<String, dynamic> reviewData = {
        'product_id': widget.productId,
        'user_id': userId,
        'content': text,
        'rating': _selectedRating,
      };

      if (_isEditing && _existingReviewId != null) {
        reviewData['id'] =
            int.tryParse(_existingReviewId!) ?? _existingReviewId;
      }

      await supabase
          .from('reviews')
          .upsert(reviewData, onConflict: 'user_id, product_id');

      Get.snackbar(
        "Success",
        _isEditing ? "Review updated!" : "Review posted!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );

      _loadReviews();
      Get.find<ProductController>().fetchProducts();
      widget.onRefresh();
    } catch (e) {
      debugPrint("Upsert Error: $e");

      showToast("Error saving review", success: false);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Reviews",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (_isEditing)
              const Text(
                "Editing your review",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueAccent,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),
        _buildInputCard(isDark),
        const SizedBox(height: 25),
        _buildReviewsList(isDark),
      ],
    );
  }

  Widget _buildInputCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: _isEditing
            ? Border.all(color: Colors.blueAccent.withOpacity(0.3))
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = index + 1),
                child: Icon(
                  index < _selectedRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 35,
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _reviewController,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: "Add your review...",
                    counterText: "",
                    filled: true,
                    fillColor: isDark ? Colors.black26 : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isSubmitting
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton.filled(
                      onPressed: _submitReview,
                      style: IconButton.styleFrom(
                        backgroundColor: _isEditing
                            ? Colors.orange
                            : Colors.blueAccent,
                      ),
                      icon: Icon(
                        _isEditing ? Icons.check : Icons.send,
                        color: Colors.white,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(bool isDark) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) return const Text("No reviews yet.");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final r = reviews[index];
            final user = r['profiles'];
            final bool isMyReview =
                r['user_id'] == supabase.auth.currentUser?.id;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 18,
                backgroundImage:
                    (user?['avatar_url'] != null &&
                        user['avatar_url'].toString().isNotEmpty)
                    ? NetworkImage(user['avatar_url'])
                    : null,
                child:
                    (user?['avatar_url'] == null ||
                        user['avatar_url'].toString().isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(
                isMyReview ? "You" : (user?['full_name'] ?? "User"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isMyReview ? Colors.blueAccent : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < (r['rating'] ?? 0)
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 14,
                      ),
                    ),
                  ),
                  Text(r['content'] ?? ""),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
