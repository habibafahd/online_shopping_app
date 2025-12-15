import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import 'feedback_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cart;
  final VoidCallback onCartCleared;

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.onCartCleared,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  double get total => widget.cart.fold(
    0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  void _placeOrder() {
    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();

      final orderId = DateTime.now().millisecondsSinceEpoch.toString();

      // Show order summary before feedback
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Order Summary"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ...widget.cart.map(
                  (item) => Text(
                    "${item.product.name} (${item.size}) x${item.quantity} - \$${(item.product.price * item.quantity).toStringAsFixed(2)}",
                  ),
                ),
                const SizedBox(height: 10),
                Text("Total: \$${total.toStringAsFixed(2)}"),
                const SizedBox(height: 10),
                Text("Phone: $phone"),
                Text("Address: $address"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Edit"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close summary

                // Clear cart immediately after order is confirmed
                widget.cart.clear();
                widget.onCartCleared();

                // Go to FeedbackScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeedbackScreen(
                      orderId: orderId,
                      onFeedbackSubmitted: () {
                        // The FeedbackScreen handles going back to home and showing the SnackBar
                      },
                    ),
                  ),
                );
              },
              child: const Text("Confirm & Feedback"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty
                    ? "Please enter your phone number"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty
                    ? "Please enter your address"
                    : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  child: const Text(
                    "Place Order",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
