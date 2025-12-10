import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductListPage extends StatelessWidget {
  final String categoryName;
  final List<Product> products;
  final Function(Product) onProductTap;
  final VoidCallback onBack;

  const ProductListPage({
    super.key,
    required this.categoryName,
    required this.products,
    required this.onProductTap,
    required this.onBack,
  });

  IconData getIconForProduct(String name) {
    switch (name.toLowerCase()) {
      case 't-shirt':
        return Icons.checkroom;
      case 'pants':
        return Icons.shopping_bag;
      case 'jacket':
        return Icons.ac_unit;
      case 'dress':
        return Icons.emoji_people;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

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
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            final icon = getIconForProduct(product.name);

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => onProductTap(product),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 60, color: Colors.blue),
                    const SizedBox(height: 10),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
