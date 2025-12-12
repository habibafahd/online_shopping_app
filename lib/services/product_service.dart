import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final CollectionReference productsCollection = FirebaseFirestore.instance
      .collection('products');

  // Get all products (optional)
  Future<List<Product>> getAllProducts() async {
    final snapshot = await productsCollection.get();
    return snapshot.docs
        .map(
          (doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  // Get products by category (new)
  Future<List<Product>> getProductsByCategory(String category) async {
    final snapshot = await productsCollection
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs
        .map(
          (doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  Future<void> addProduct(Product product) async {
    await productsCollection.doc(product.id).set(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await productsCollection.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await productsCollection.doc(id).delete();
  }
}
