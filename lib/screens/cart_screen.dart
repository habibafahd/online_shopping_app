import 'package:flutter/material.dart';
import '../models/cart_item.dart';

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
    (sum, item) => sum + item.product.price * item.quantity,
  );

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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Order submitted!")),
                          );
                        },
                        child: const Text("Checkout"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
