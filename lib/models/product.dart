import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? description;
  final IconData icon;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.stock = 10,
    this.description,
    required this.icon,
  });

  // Convert IconData to string for Firestore
  String get iconString {
    if (icon == Icons.checkroom) return "checkroom";
    if (icon == Icons.shopping_bag) return "shopping_bag";
    if (icon == Icons.ac_unit) return "ac_unit";
    return "category";
  }

  // Optional: factory from Firestore map
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    IconData iconData;
    switch (map['icon']) {
      case "checkroom":
        iconData = Icons.checkroom;
        break;
      case "shopping_bag":
        iconData = Icons.shopping_bag;
        break;
      case "ac_unit":
        iconData = Icons.ac_unit;
        break;
      default:
        iconData = Icons.category;
    }
    return Product(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      stock: map['stock'] ?? 10,
      description: map['description'],
      icon: iconData,
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'description': description,
      'icon': iconString,
    };
  }
}
