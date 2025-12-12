import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_details_page.dart';

class ProductListPage extends StatefulWidget {
  final String categoryName;
  final List<Product> products;
  final Function(Product, String) onAddToCart;
  final Function(Widget) onOpenPage;

  const ProductListPage({
    super.key,
    required this.categoryName,
    required this.products,
    required this.onAddToCart,
    required this.onOpenPage,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final filteredProducts = widget.products
        .where((p) => p.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: "Search in category...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() => searchText = val),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return GestureDetector(
                  onTap: () {
                    widget.onOpenPage(
                      ProductDetailsPage(
                        product: product,
                        onAddToCart: widget.onAddToCart,
                        onBack: () => widget.onOpenPage(
                          ProductListPage(
                            categoryName: widget.categoryName,
                            products: widget.products,
                            onAddToCart: widget.onAddToCart,
                            onOpenPage: widget.onOpenPage,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(product.icon, size: 60, color: Colors.blue),
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
        ],
      ),
    );
  }
}
