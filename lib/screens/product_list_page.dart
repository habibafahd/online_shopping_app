import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_details_page.dart';

class ProductListPage extends StatelessWidget {
  final String categoryName;
  final List<Product> products;
  final VoidCallback onBack;
  final void Function(Product, String) onAddToCart;

  const ProductListPage({
    super.key,
    required this.categoryName,
    required this.products,
    required this.onBack,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // Optional: open details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(
                          product: product,
                          onAddToCart: onAddToCart,
                          onBack: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                  child: Icon(product.icon, size: 60, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${product.price}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 100,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => onAddToCart(product, "M"),
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
