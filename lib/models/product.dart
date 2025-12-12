import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final IconData icon;
  final double price;
  final int stock;
  final String category; // NEW
  final String? description; // NEW

  Product({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    this.stock = 10,
    required this.category,
    this.description,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'],
      icon: IconData(data['icon'], fontFamily: 'MaterialIcons'),
      price: (data['price'] as num).toDouble(),
      stock: data['stock'] ?? 10,
      category: data['category'] ?? "Uncategorized",
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon.codePoint,
      'price': price,
      'stock': stock,
      'category': category,
      'description': description,
    };
  }
}
