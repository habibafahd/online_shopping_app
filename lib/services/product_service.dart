import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final CollectionReference productsCollection = FirebaseFirestore.instance
      .collection('products');

  Future<List<Product>> getAllProducts() async {
    final snapshot = await productsCollection.get();
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
