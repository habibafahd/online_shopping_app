import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as my_order;
import '../models/cart_item.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addOrder({
    required String userId,
    required String orderId,
    required List<CartItem> cart,
    required double total,
    required String phone,
    required String address,
  }) async {
    final orderData = {
      "total": total,
      "items": cart
          .map(
            (c) => {
              "productId": c.product.id,
              "name": c.product.name,
              "price": c.product.price,
              "size": c.size,
              "quantity": c.quantity,
            },
          )
          .toList(),
      "phone": phone,
      "address": address,
      "date": DateTime.now(),
    };

    await _db
        .collection("users")
        .doc(userId)
        .collection("orders")
        .doc(orderId)
        .set(orderData);
  }

  Future<void> addFeedback({
    required String orderId,
    required double rating,
    required String comment,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");

    await _db
        .collection("users")
        .doc(userId)
        .collection("orders")
        .doc(orderId)
        .collection("feedback")
        .add({"rating": rating, "comment": comment, "date": DateTime.now()});
  }
}
