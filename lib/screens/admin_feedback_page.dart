import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFeedbackPage extends StatefulWidget {
  const AdminFeedbackPage({super.key});

  @override
  State<AdminFeedbackPage> createState() => _AdminFeedbackPageState();
}

class _AdminFeedbackPageState extends State<AdminFeedbackPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Feedback')),
      body: StreamBuilder<QuerySnapshot>(
        // Fetch all feedback documents across all users/orders
        stream: _db.collectionGroup('feedback').snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // No feedback found
          final feedbackDocs = snapshot.data!.docs;
          if (feedbackDocs.isEmpty) {
            return const Center(child: Text('No feedback found'));
          }

          // Display all feedbacks
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              final fbDoc = feedbackDocs[index];
              final data = fbDoc.data() as Map<String, dynamic>;

              // Extract userId and orderId from Firestore document path
              // Path format: users/{userId}/orders/{orderId}/feedback/{feedbackId}
              final pathSegments = fbDoc.reference.path.split('/');
              final userId = pathSegments[1];
              final orderId = pathSegments[3];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      data['rating']?.toString() ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(data['comment'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User ID: $userId'),
                      Text('Order ID: $orderId'),
                      if (data['date'] != null)
                        Text(
                          (data['date'] as Timestamp)
                              .toDate()
                              .toLocal()
                              .toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
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
