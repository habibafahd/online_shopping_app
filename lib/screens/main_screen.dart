import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/product_service.dart';
import 'cart_screen.dart';
import 'product_list_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<CartItem> cart = [];
  Widget? currentScreen;

  List<Product> allProducts = [];
  List<String> categories = [];
  List<String> filteredCategories = [];

  final ProductService productService = ProductService();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    allProducts = await productService.getAllProducts();
    categories = allProducts.map((p) => p.category).toSet().toList();
    filteredCategories = List.from(categories);
    setState(() {});
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      filteredCategories = List.from(categories);
    } else {
      filteredCategories = categories
          .where((c) => c.toLowerCase().contains(query))
          .toList();
    }
    setState(() {});
  }

  void openScreen(Widget screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  void addToCart(Product product, [String size = 'M']) {
    final existing = cart.indexWhere(
      (item) => item.product.id == product.id && item.size == size,
    );
    if (existing >= 0) {
      cart[existing].quantity++;
    } else {
      cart.add(CartItem(product: product, size: size));
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Added ${product.name} to cart")));
  }

  void onCategoryTap(String categoryName) {
    final products = allProducts
        .where((p) => p.category == categoryName)
        .toList();
    openScreen(
      ProductListPage(
        categoryName: categoryName,
        products: products,
        onBack: () => setState(() => currentScreen = null),
        onAddToCart: addToCart,
      ),
    );
  }

  void onCartTap() {
    openScreen(
      CartScreen(
        cart: cart,
        onCartChanged: () => setState(() {}),
        onBack: () => setState(() => currentScreen = null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body =
        currentScreen ??
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search categories...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredCategories.isEmpty
                  ? const Center(child: Text("No categories found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.category,
                              color: Colors.blue,
                              size: 40,
                            ),
                            title: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () => onCategoryTap(category),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            currentScreen = null;
          });
          if (index == 1) onCartTap();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
        ],
      ),
    );
  }
}
