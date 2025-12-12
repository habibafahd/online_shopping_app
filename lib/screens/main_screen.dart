import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import '../services/product_service.dart';
import 'product_list_page.dart';
import 'product_details_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<CartItem> cart = [];
  late Widget currentScreen;

  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    // Start with HomeScreen and pass callbacks
    currentScreen = HomeScreen(
      onAddToCart: addToCart,
      onOpenPage: openScreen,
      onCategoryTap: onCategoryTap,
    );
  }

  void openScreen(Widget screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  void addToCart(Product product, [String size = "M"]) {
    final index = cart.indexWhere(
      (item) => item.product.id == product.id && item.size == size,
    );
    if (index >= 0) {
      cart[index].quantity++;
    } else {
      cart.add(CartItem(product: product, size: size));
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Added ${product.name} to cart")));
  }

  void onCategoryTap(String categoryName) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final products = await _productService.getProductsByCategory(
        categoryName,
      );
      Navigator.pop(context); // remove loading indicator

      openScreen(
        ProductListPage(
          categoryName: categoryName,
          products: products,
          onAddToCart: addToCart,
          onOpenPage: openScreen,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load products: $e")));
    }
  }

  void onCartTap() {
    openScreen(
      CartScreen(
        cart: cart,
        onCartChanged: () => setState(() {}),
        onBack: () => openScreen(
          HomeScreen(
            onAddToCart: addToCart,
            onOpenPage: openScreen,
            onCategoryTap: onCategoryTap,
          ),
        ),
      ),
    );
  }

  void onProfileTap() {
    openScreen(ProfileScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) {
              openScreen(
                HomeScreen(
                  onAddToCart: addToCart,
                  onOpenPage: openScreen,
                  onCategoryTap: onCategoryTap,
                ),
              );
            } else if (index == 1) {
              onCartTap();
            } else if (index == 2) {
              onProfileTap();
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
