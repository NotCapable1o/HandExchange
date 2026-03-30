import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controllers/product_controller.dart';
import '../views/product_details_screen.dart';

class ProductSearchDelegate extends SearchDelegate {
  final ProductController controller = Get.find();
  final storage = GetStorage();
  final String _historyKey = 'search_history';

  List<dynamic> get _history => storage.read<List>(_historyKey) ?? [];

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results = controller.products
        .where(
          (p) =>
              p['title'].toString().toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return _buildProductList(results, isHistory: false);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return StatefulBuilder(
        builder: (context, setLocalState) {
          final historyList = _history;

          if (historyList.isEmpty) {
            return const Center(
              child: Text(
                "Search for products...",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Searches",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        storage.write(_historyKey, []);
                        setLocalState(() {});
                      },
                      child: const Text(
                        "Clear All",
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildProductList(
                  historyList,
                  isHistory: true,
                  onDelete: () => setLocalState(() {}),
                ),
              ),
            ],
          );
        },
      );
    }

    final suggestions = controller.products
        .where(
          (p) =>
              p['title'].toString().toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return _buildProductList(suggestions, isHistory: false);
  }

  Widget _buildProductList(
    List<dynamic> list, {
    required bool isHistory,
    VoidCallback? onDelete,
  }) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = Map<String, dynamic>.from(list[index]);
        final String imageUrl =
            (item['images'] != null && item['images'].isNotEmpty)
            ? item['images'][0].toString()
            : 'https://via.placeholder.com/150';

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image),
            ),
          ),
          title: Text(item['title'] ?? "No Title"),
          subtitle: Text(
            item['is_donation'] == true ? "FREE" : "৳${item['price']}",
          ),
          trailing: isHistory
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () {
                    _removeFromHistory(item['id']);
                    if (onDelete != null) onDelete();
                  },
                )
              : null,
          onTap: () {
            _addToHistory(item);
            Get.to(() => ProductDetailsScreen(product: item));
          },
        );
      },
    );
  }

  void _addToHistory(Map<String, dynamic> item) {
    List<dynamic> currentHistory = List.from(_history);
    currentHistory.removeWhere((element) => element['id'] == item['id']);
    currentHistory.insert(0, item);
    if (currentHistory.length > 10) currentHistory.removeLast();
    storage.write(_historyKey, currentHistory);
  }

  void _removeFromHistory(dynamic id) {
    List<dynamic> currentHistory = List.from(_history);
    currentHistory.removeWhere((element) => element['id'] == id);
    storage.write(_historyKey, currentHistory);
  }
}
