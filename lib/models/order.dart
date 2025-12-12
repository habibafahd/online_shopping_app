import 'package:online_shopping_app/models/cart_item.dart';

class Order {
  final String id;
  final double total;
  final List<Map<String, dynamic>> items; // store cart items as Map
  final DateTime date;
  final String userId;
  final String? feedback;
  final int? rating;

  Order({
    required this.id,
    required this.total,
    required this.items,
    required this.date,
    required this.userId,
    this.feedback,
    this.rating,
  });

  // Convert Order to Map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'items': items,
      'date': date.toIso8601String(),
      'userId': userId,
      'feedback': feedback,
      'rating': rating,
    };
  }

  // Create Order object from Firestore map
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      total: map['total'],
      items: List<Map<String, dynamic>>.from(map['items']),
      date: DateTime.parse(map['date']),
      userId: map['userId'],
      feedback: map['feedback'],
      rating: map['rating'],
    );
  }
}
