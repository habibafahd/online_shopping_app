import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_list_page.dart';

class HomeScreen extends StatefulWidget {
  final Function(Product, String) onAddToCart;
  final Function(Widget) onOpenPage;
  final Function(String) onCategoryTap;

  const HomeScreen({
    super.key,
    required this.onAddToCart,
    required this.onOpenPage,
    required this.onCategoryTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.checkroom, "name": "T-Shirt"},
    {"icon": Icons.shopping_bag, "name": "Pants"},
    {"icon": Icons.ac_unit, "name": "Jacket"},
    {"icon": Icons.ac_unit, "name": "Dress"},
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> categoryWidgets = categories
        .where(
          (item) =>
              searchText.isEmpty ||
              item["name"].toString().toLowerCase().contains(searchText),
        )
        .map<Widget>((item) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(item["icon"], size: 40, color: Colors.blue),
              title: Text(
                item["name"],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => widget.onCategoryTap(item["name"]),
            ),
          );
        })
        .toList();

    if (searchText.isNotEmpty && categoryWidgets.isEmpty) {
      categoryWidgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              "No products found",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search products...",
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Categories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Expanded(child: ListView(children: categoryWidgets)),
        ],
      ),
    );
  }
}
