import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import 'feedback_screen.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cart;
  final VoidCallback onCartChanged;
  final VoidCallback onBack;

  const CartScreen({
    super.key,
    required this.cart,
    required this.onCartChanged,
    required this.onBack,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get total => widget.cart.fold(
    0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  Future<void> _checkout() async {
    final userId = AuthService().currentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("You must be logged in!")));
      return;
    }

    String phone = '';
    String address = '';

    // Collect phone and address
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter your details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
                onChanged: (val) => phone = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Address"),
                onChanged: (val) => address = val,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (phone.isEmpty || address.isEmpty) return;
                Navigator.pop(context);
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );

    if (phone.isEmpty || address.isEmpty) return;

    // Create order
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    await OrderService().addOrder(
      userId: userId,
      orderId: orderId,
      cart: widget.cart,
      total: total,
      phone: phone,
      address: address,
    );

    widget.cart.clear();
    widget.onCartChanged();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Order placed successfully!")));

    // Open feedback screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedbackScreen(
          orderId: orderId,
          onFeedbackSubmitted: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Thank you for your feedback!")),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: widget.cart.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: Icon(
                            item.product.icon,
                            size: 40,
                            color: Colors.blue,
                          ),
                          title: Text("${item.product.name} (${item.size})"),
                          subtitle: Text(
                            "\$${item.product.price} x ${item.quantity}",
                          ),
                          trailing: SizedBox(
                            width: 140,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      if (item.quantity > 1) {
                                        item.quantity--;
                                      } else {
                                        widget.cart.removeAt(index);
                                      }
                                      widget.onCartChanged();
                                    });
                                  },
                                ),
                                Text(item.quantity.toString()),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      item.quantity++;
                                      widget.onCartChanged();
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      widget.cart.removeAt(index);
                                      widget.onCartChanged();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: \$${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _checkout,
                        child: const Text("Place Order"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
