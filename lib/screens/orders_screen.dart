import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import '../models/order.dart' as my_order;

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUserId();

    return Scaffold(
      appBar: AppBar(title: const Text("Orders")),
      body: FutureBuilder<List<my_order.Order>>(
        future: OrderService().getOrdersByUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders yet"));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Order #${order.id}"),
                  subtitle: Text(
                    "Total: \$${order.total.toStringAsFixed(2)}\n"
                    "Date: ${order.date.toLocal()}",
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
