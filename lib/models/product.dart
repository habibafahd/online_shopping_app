import 'package:flutter/material.dart';

class Product {
  final String id; // Firestore document ID
  final String name;
  final IconData icon;
  final double price;
  final int stock;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    this.stock = 10,
    this.category = 'Clothes',
  });

  // Convert Firestore data to Product
  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      icon: _getIcon(data['name'] ?? ''),
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      stock: data['stock'] ?? 10,
      category: data['category'] ?? 'Clothes',
    );
  }

  static IconData _getIcon(String name) {
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

  // Convert Product to Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'stock': stock, 'category': category};
  }
}
