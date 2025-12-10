import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'product_list_page.dart';
import 'home_screen.dart';
import 'product_details_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<CartItem> cart = [];
  Widget? currentScreen;

  void openScreen(Widget screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  void addToCart(Product product, String size) {
    final existing = cart.indexWhere(
      (item) => item.product.id == product.id && item.size == size,
    );
    if (existing >= 0) {
      cart[existing].quantity++;
    } else {
      cart.add(CartItem(product: product, size: size));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Added ${product.name} size $size to cart")),
    );
  }

  void onCategoryTap(String categoryName) async {
    final products = await ProductService().getProducts(categoryName);
    openScreen(
      ProductListPage(
        categoryName: categoryName,
        products: products,
        onProductTap: onProductTap,
        onBack: () => setState(() => currentScreen = null),
      ),
    );
  }

  void onProductTap(Product product) {
    openScreen(
      ProductDetailsPage(
        product: product,
        onAddToCart: addToCart,
        onBack: () => setState(() => currentScreen = null),
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

  void onProfileTap() {
    openScreen(const ProfileScreen());
  }

  void onOrdersTap() {
    openScreen(const OrdersScreen());
  }

  @override
  Widget build(BuildContext context) {
    Widget body = currentScreen ?? HomeScreen(onCategoryTap: onCategoryTap);

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
          switch (index) {
            case 0:
              currentScreen = null;
              break;
            case 1:
              onCartTap();
              break;
            case 2:
              onOrdersTap();
              break;
            case 3:
              onProfileTap();
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
