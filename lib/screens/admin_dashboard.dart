import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'admin_product_management.dart';
import 'admin_category_management.dart';
import 'admin_reports_page.dart';
import 'admin_feedback_page.dart';
import 'admin_best_selling_page.dart'; // <-- imported the new page

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _auth = AuthService();
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminProductsPage(),
    AdminCategoriesPage(),
    AdminOrdersPage(),
    AdminFeedbackPage(),
    AdminBestSellingPage(), // <-- added best-selling chart page
  ];

  final List<String> _titles = [
    'Products',
    'Categories',
    'Reports',
    'Feedback',
    'Best Selling Products', // <-- title for new page
  ];

  void _logout() async {
    await _auth.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Best Selling',
          ),
        ],
      ),
    );
  }
}
