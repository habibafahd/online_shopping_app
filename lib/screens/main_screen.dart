import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'cart_screen.dart';
import 'product_list_page.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../services/product_service.dart';

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
    // Pass addToCart to HomeScreen
    currentScreen = HomeScreen(onAddToCart: addToCart);
  }

  void openScreen(Widget screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  void addToCart(Product product, [String size = "M"]) {
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

  void onCategoryTap(String categoryName) async {
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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductListPage(
            categoryName: categoryName,
            products: products,
            onBack: () => Navigator.pop(context),
            onAddToCart: addToCart, // pass MainScreen's cart method
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // remove loading indicator
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
        onBack: () => openScreen(HomeScreen(onAddToCart: addToCart)),
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
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) {
              openScreen(HomeScreen(onAddToCart: addToCart));
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
