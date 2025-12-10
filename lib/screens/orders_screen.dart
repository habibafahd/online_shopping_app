import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = AuthService().currentUserId();

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to see orders")),
      );
    }

    final ordersRef = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("Orders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders yet"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final items = (data['items'] as List<dynamic>)
                  .map((e) => "${e['name']} x${e['quantity']}")
                  .join(", ");

              final date = (data['date'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Order #${data['id']}"),
                  subtitle: Text(
                    "Items: $items\nTotal: \$${data['total']}\nDate: ${date.toLocal()}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
