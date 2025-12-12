import 'package:flutter/material.dart';
import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  final Function(String) onCategoryTap;

  const HomeScreen({super.key, required this.onCategoryTap});

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
        .map((item) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("ShopEasy"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
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
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {
                      // TODO: Implement voice search
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () {
                      // TODO: Implement barcode scanner
                    },
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
      ),
    );
  }
}
