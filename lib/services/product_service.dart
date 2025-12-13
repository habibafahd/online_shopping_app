import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductService {
  final CollectionReference productsCollection = FirebaseFirestore.instance
      .collection('products');

  // Helper: map icon string from Firestore to IconData
  IconData getIconFromString(String iconName) {
    switch (iconName) {
      case "checkroom":
        return Icons.checkroom;
      case "shopping_bag":
        return Icons.shopping_bag;
      case "ac_unit":
        return Icons.ac_unit;
      default:
        return Icons.category;
    }
  }

  // Convert Firestore doc to Product
  Product _productFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      description: data['description'],
      icon: getIconFromString(data['icon'] ?? 'category'),
      barcode: data['barcode'] ?? '', // <-- add barcode here
    );
  }

  // Get all products (optional)
  Future<List<Product>> getAllProducts() async {
    final snapshot = await productsCollection.get();
    return snapshot.docs.map(_productFromDoc).toList();
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    final snapshot = await productsCollection
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs.map(_productFromDoc).toList();
  }

  // Add a new product
  Future<void> addProduct(Product product) async {
    await productsCollection.doc(product.id).set({
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'stock': product.stock,
      'description': product.description,
      'icon': product.iconString,
      'barcode': product.barcode, // <-- include barcode
    });
  }

  // Update existing product
  Future<void> updateProduct(Product product) async {
    await productsCollection.doc(product.id).update({
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'stock': product.stock,
      'description': product.description,
      'icon': product.iconString,
      'barcode': product.barcode, // <-- include barcode
    });
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    await productsCollection.doc(id).delete();
  }
}
