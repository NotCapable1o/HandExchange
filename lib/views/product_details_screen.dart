import 'package:HandExchange/views/product_reviews_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/cart_controller.dart';
import '../controllers/chat_controller.dart';
import '../controllers/product_controller.dart';
import '../utils/toast.dart';
import '../widgets/product_details/product_description_section.dart';
import '../widgets/product_details/product_header_section.dart';
import '../widgets/product_details/product_image_carousel.dart';
import '../widgets/product_details/product_info_rows.dart';
import '../widgets/product_details/product_location_map.dart';
import '../widgets/product_details/product_seller_card.dart';
import 'chat_detail_screen.dart';
import 'login_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductController controller = Get.find<ProductController>();
  final ChatController chatController = Get.put(ChatController());
  final CartController cartController = Get.find<CartController>();
  final supabase = Supabase.instance.client;

  bool isFavorite = false;
  int likeCount = 0;
  bool isLiked = false;
  bool isDisliked = false;
  bool isLoadingInteractions = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  bool _isLoggedIn() => supabase.auth.currentUser != null;

  void _requireAuth(VoidCallback action) {
    if (_isLoggedIn()) {
      action();
    } else {
      Get.to(() => const LoginScreen());
      showToast("Please login first", success: false);
    }
  }

  Future<void> _handleRefresh() async {
    await _loadInitialData();
    try {
      final updatedData = await supabase
          .from('products_with_reviews')
          .select('calculated_avg, calculated_count')
          .eq('id', widget.product['id'])
          .single();

      if (mounted) {
        setState(() {
          widget.product['calculated_avg'] = updatedData['calculated_avg'];
          widget.product['calculated_count'] = updatedData['calculated_count'];
        });
      }
    } catch (e) {
      debugPrint("Refreshed stats error: $e");
    }
  }

  Future<void> _loadInitialData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => isLoadingInteractions = false);
      return;
    }

    final productId = widget.product['id'];

    try {
      final results = await Future.wait<dynamic>([
        supabase.from('favorites').select().match({
          'user_id': userId,
          'product_id': productId,
        }).maybeSingle(),
        supabase.from('reactions').select('is_like').match({
          'user_id': userId,
          'product_id': productId,
        }).maybeSingle(),
        supabase
            .from('reactions')
            .count(CountOption.exact)
            .eq('product_id', productId)
            .eq('is_like', true),
      ]);

      if (mounted) {
        setState(() {
          isFavorite = results[0] != null;
          if (results[1] != null) {
            isLiked = results[1]['is_like'] == true;
            isDisliked = results[1]['is_like'] == false;
          } else {
            isLiked = false;
            isDisliked = false;
          }
          likeCount = results[2] as int;
        });
      }
    } catch (e) {
      debugPrint("Preload error: $e");
    } finally {
      if (mounted) setState(() => isLoadingInteractions = false);
    }
  }

  Future<void> _toggleFavorite() async {
    _requireAuth(() async {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      setState(() => isFavorite = !isFavorite);
      HapticFeedback.lightImpact();

      try {
        if (isFavorite) {
          await supabase.from('favorites').insert({
            'user_id': userId,
            'product_id': widget.product['id'],
          });
        } else {
          await supabase.from('favorites').delete().match({
            'user_id': userId,
            'product_id': widget.product['id'],
          });
        }
      } catch (e) {
        setState(() => isFavorite = !isFavorite);
        showToast("Sync failed", success: false);
      }
    });
  }

  Future<void> _updateReaction(bool isLikeAction) async {
    _requireAuth(() async {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final bool prevLiked = isLiked;
      final bool prevDisliked = isDisliked;
      final int prevCount = likeCount;

      setState(() {
        if (isLikeAction) {
          if (isLiked) {
            isLiked = false;
            likeCount--;
          } else {
            if (isDisliked) isDisliked = false;
            isLiked = true;
            likeCount++;
          }
        } else {
          if (isDisliked) {
            isDisliked = false;
          } else {
            if (isLiked) {
              isLiked = false;
              likeCount--;
            }
            isDisliked = true;
          }
        }
      });

      HapticFeedback.lightImpact();

      try {
        if (!isLiked && !isDisliked) {
          await supabase.from('reactions').delete().match({
            'user_id': userId,
            'product_id': widget.product['id'],
          });
        } else {
          await supabase.from('reactions').upsert({
            'user_id': userId,
            'product_id': widget.product['id'],
            'is_like': isLiked,
          });
        }
      } catch (e) {
        setState(() {
          isLiked = prevLiked;
          isDisliked = prevDisliked;
          likeCount = prevCount;
        });
        showToast("Sync failed. Check connection.", success: false);
      }
    });
  }

  void _startChat() async {
    _requireAuth(() async {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      try {
        final sellerId =
            widget.product['user_id'] ?? widget.product['seller_id'];
        if (sellerId == null) throw "Seller ID not found";

        String roomId = await chatController.getOrCreateRoom(
          widget.product['id'],
          sellerId,
        );
        String actualSellerName =
            widget.product['profiles']?['full_name'] ?? "Unknown Seller";

        Get.back();
        Get.to(
          () =>
              ChatDetailScreen(roomId: roomId, otherUserName: actualSellerName),
        );
      } catch (e) {
        Get.back();
        showToast("Chat Error: Could not start chat", success: false);
      }
    });
  }

  void _confirmDelete() {
    Get.defaultDialog(
      title: "Delete Listing?",
      middleText: "This action cannot be undone.",
      backgroundColor: Theme.of(context).cardColor,
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onCancel: () {
        if (Get.isDialogOpen!) Get.back(closeOverlays: false);
      },
      onConfirm: () async {
        if (Get.isDialogOpen!) Get.back();
        await controller.deleteProduct(widget.product['id']);
        Get.back();
        showToast("Listing deleted");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List images = widget.product['images'] ?? [];
    final bool isOwner =
        (widget.product['user_id'] ?? widget.product['seller_id']) ==
        supabase.auth.currentUser?.id;
    final double lat = (widget.product['lat'] as num?)?.toDouble() ?? 23.8103;
    final double lng = (widget.product['lng'] as num?)?.toDouble() ?? 90.4125;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImageCarousel(images: images),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductHeaderSection(
                      product: widget.product,
                      isLoadingInteractions: isLoadingInteractions,
                      isLiked: isLiked,
                      isDisliked: isDisliked,
                      likeCount: likeCount,
                      onReactionPressed: _updateReaction,
                    ),
                    const Divider(height: 40, thickness: 1),

                    ProductInfoRows(product: widget.product),
                    const SizedBox(height: 30),

                    ProductDescriptionSection(
                      description:
                          widget.product['description'] ??
                          "No description provided.",
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      "Pickup Location Map",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ProductLocationMap(lat: lat, lng: lng),
                    const SizedBox(height: 20),

                    ProductSellerCard(
                      profiles: widget.product['profiles'],
                      isOwner: isOwner,
                    ),
                    const Divider(height: 40, thickness: 1),

                    const Row(
                      children: [
                        Icon(Icons.reviews_outlined, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Text(
                          "Customer Reviews",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (!_isLoggedIn()) _requireAuth(() {});
                      },
                      child: AbsorbPointer(
                        absorbing: !_isLoggedIn(),
                        child: ProductReviewsWidget(
                          productId: widget.product['id'].toString(),
                          onRefresh: _handleRefresh,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: !isOwner ? _buildBottomActions(context) : null,
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: ElevatedButton.icon(
                onPressed: _startChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                ),
                label: const Text(
                  "Chat with Seller",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 15),
            IconButton.filledTonal(
              onPressed: () => _requireAuth(() {
                HapticFeedback.lightImpact();
                cartController.addToCart(widget.product['id']);
                showToast("Added to Cart");
              }),
              icon: const Icon(Icons.add_shopping_cart),
            ),
          ],
        ),
      ),
    );
  }
}
