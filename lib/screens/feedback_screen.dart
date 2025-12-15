import 'package:flutter/material.dart';
import '../services/order_service.dart';

class FeedbackScreen extends StatefulWidget {
  final String orderId;
  final VoidCallback onFeedbackSubmitted;

  const FeedbackScreen({
    super.key,
    required this.orderId,
    required this.onFeedbackSubmitted,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double rating = 5;
  String comment = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Rate your experience", style: TextStyle(fontSize: 18)),
            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: rating.toString(),
              onChanged: (val) => setState(() => rating = val),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Comment"),
              onChanged: (val) => comment = val,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await OrderService().addFeedback(
                  orderId: widget.orderId,
                  rating: rating,
                  comment: comment,
                );

                // Navigate to home immediately after feedback
                widget
                    .onFeedbackSubmitted(); // This can clear cart in CheckoutScreen
                if (Navigator.canPop(context)) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }

                // Show SnackBar on home screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thank you for your feedback!")),
                );
              },
              child: const Text("Submit Feedback"),
            ),
          ],
        ),
      ),
    );
  }
}
