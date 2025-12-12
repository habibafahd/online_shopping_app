import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'cart_screen.dart';
import 'product_list_page.dart';
import 'product_details_page.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<CartItem> cart = [];
  late Widget currentScreen;

  @override
  void initState() {
    super.initState();
    currentScreen = HomeScreen(onCategoryTap: onCategoryTap);
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

  void onCategoryTap(String categoryName) {
    // Here, you will later load products from Firebase for that category
    List<Product> products = []; // start empty; admin adds products to Firebase

    openScreen(
      ProductListPage(
        categoryName: categoryName,
        products: products,
        onBack: () => openScreen(HomeScreen(onCategoryTap: onCategoryTap)),
        onAddToCart: addToCart,
      ),
    );
  }

  void onCartTap() {
    openScreen(
      CartScreen(
        cart: cart,
        onCartChanged: () => setState(() {}),
        onBack: () => openScreen(HomeScreen(onCategoryTap: onCategoryTap)),
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
              openScreen(HomeScreen(onCategoryTap: onCategoryTap));
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
