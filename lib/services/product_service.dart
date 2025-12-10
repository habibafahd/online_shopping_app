import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'package:flutter/material.dart'; // Add this to use Icons

class ProductService {
  final CollectionReference productsRef = FirebaseFirestore.instance.collection(
    'products',
  );

  Future<List<Product>> getProducts(String category) async {
    final snapshot = await productsRef
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Product(
        id: doc.id,
        name: data['name'],
        price: (data['price'] as num).toDouble(),
        icon: _getIcon(data['name']),
        stock: data['stock'] ?? 10,
      );
    }).toList();
  }

  IconData _getIcon(String name) {
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
}
