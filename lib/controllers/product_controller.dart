import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

import '../utils/toast.dart';

class ProductController extends GetxController {
  final supabase = Supabase.instance.client;

  var products = <dynamic>[].obs;
  var filteredProducts = <dynamic>[].obs;
  var isLoading = false.obs;
  var selectedCategory = "All".obs;

  var isFavLoading = false.obs;
  var favoriteProducts = <dynamic>[].obs;

  var currentProductReviews = <dynamic>[].obs;
  var averageRating = 0.0.obs;

  var activeSort = 'default'.obs;
  var minPrice = 0.0.obs;
  var maxPrice = 100000.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('products_with_reviews')
          .select('*, profiles!user_id(full_name, avatar_url)')
          .order('created_at', ascending: false);

      products.assignAll(response);
      filterByCategory(selectedCategory.value);
    } catch (e) {
      debugPrint("DATABASE FETCH ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;

    activeSort.value = 'default';
    minPrice.value = 0.0;
    maxPrice.value = 100000.0;

    if (category == "All") {
      filteredProducts.assignAll(List<Map<String, dynamic>>.from(products));
    } else {
      var filtered = products.where((p) => p['category'] == category).toList();
      filteredProducts.assignAll(List<Map<String, dynamic>>.from(filtered));
    }
  }

  void resetFilters() {
    minPrice.value = 0.0;
    maxPrice.value = 100000.0;
    activeSort.value = 'default';

    filterByCategory(selectedCategory.value);
  }

  Future<bool> addProduct(
    Map<String, dynamic> productData,
    List<File> imageFiles,
  ) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        showToast("You must be logged in", success: false);
        return false;
      }

      List<String> imageUrls = [];

      for (File file in imageFiles) {
        final fileExt = p.extension(file.path);

        final fileName =
            "${userId}_${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}$fileExt";

        await supabase.storage.from('product-images').upload(fileName, file);
        final publicUrl = supabase.storage
            .from('product-images')
            .getPublicUrl(fileName);
        imageUrls.add(publicUrl);
      }

      productData['images'] = imageUrls;
      productData['user_id'] = userId;

      productData['price'] = productData['price'] ?? 0;
      productData['lat'] = productData['lat'] ?? 0.0;
      productData['lng'] = productData['lng'] ?? 0.0;

      await supabase.from('products').insert(productData);
      await fetchProducts();

      return true;
    } catch (e) {
      debugPrint("ADD PRODUCT ERROR: $e");
      return false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await supabase.from('products').delete().eq('id', productId);
      products.removeWhere((p) => p['id'] == productId);
      filterByCategory(selectedCategory.value);
      showToast("Listing deleted");
    } catch (e) {
      showToast("Delete failed", success: false);
    }
  }

  Future<void> fetchFavorites() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      isFavLoading.value = true;

      final data = await supabase
          .from('favorites')
          .select('*, products(*)')
          .eq('user_id', userId);

      favoriteProducts.value = data.map((fav) => fav['products']).toList();
    } catch (e) {
      debugPrint("Fav Fetch Error: $e");
    } finally {
      isFavLoading.value = false;
    }
  }

  Future<void> removeFromFavorites(dynamic productId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    favoriteProducts.removeWhere((item) => item['id'] == productId);

    try {
      await supabase.from('favorites').delete().match({
        'user_id': userId,
        'product_id': productId,
      });
    } catch (e) {
      fetchFavorites();
      debugPrint("Remove Fav Error: $e");
    }
  }

  Future<void> fetchProductReviews(String productId) async {
    try {
      final data = await supabase
          .from('reviews')
          .select('*, profiles(full_name, avatar_url)')
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      currentProductReviews.value = data;

      if (data.isNotEmpty) {
        double total = 0;
        for (var item in data) {
          total += (item['rating'] ?? 0).toDouble();
        }
        averageRating.value = total / data.length;
      } else {
        averageRating.value = 0.0;
      }
    } catch (e) {
      debugPrint("Review Error: $e");
    }
  }
}
