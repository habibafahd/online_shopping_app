import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as my_order;

class OrderService {
  final CollectionReference ordersCollection = FirebaseFirestore.instance
      .collection('orders');

  // Add a new order
  Future<void> addOrder(my_order.Order order) async {
    await ordersCollection.doc(order.id).set({
      'id': order.id,
      'total': order.total,
      'items': order.items,
      'date': order.date.toIso8601String(),
      'userId': order.userId,
    });
  }

  // Get orders by user
  Future<List<my_order.Order>> getOrdersByUser(String userId) async {
    final snapshot = await ordersCollection
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return my_order.Order(
        id: data['id'],
        total: (data['total'] as num).toDouble(),
        items: List<Map<String, dynamic>>.from(data['items']),
        date: DateTime.parse(data['date']),
        userId: data['userId'],
      );
    }).toList();
  }

  // Get all orders (for admin)
  Future<List<my_order.Order>> getAllOrders() async {
    final snapshot = await ordersCollection.get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return my_order.Order(
        id: data['id'],
        total: (data['total'] as num).toDouble(),
        items: List<Map<String, dynamic>>.from(data['items']),
        date: DateTime.parse(data['date']),
        userId: data['userId'],
      );
    }).toList();
  }
}
