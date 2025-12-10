import 'package:flutter/material.dart';
import '../models/product.dart';
import 'main_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(String) onCategoryTap;

  // Removed 'const' from constructor
  HomeScreen({super.key, required this.onCategoryTap});

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.shopping_bag_outlined, "name": "Clothes"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ShopEasy",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.mic), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () {},
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
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
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
                      onTap: () => onCategoryTap(item["name"]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
