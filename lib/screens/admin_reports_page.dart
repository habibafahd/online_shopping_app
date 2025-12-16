import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _allFeedback = [];

  @override
  void initState() {
    super.initState();
    print("AdminReports initialized");
    _fetchAllFeedback();
  }

  // ------------------ Fetch all feedback ------------------
  Future<void> _fetchAllFeedback() async {
    print("Fetching all feedbacks...");

    final usersSnap = await _firestore.collection('users').get();
    if (usersSnap.docs.isEmpty) {
      print("Users collection is empty!");
      return;
    }
    print("Total users found: ${usersSnap.docs.length}");

    for (var userDoc in usersSnap.docs) {
      final ordersSnap = await userDoc.reference.collection('orders').get();
      print("User: ${userDoc.id} - Orders fetched: ${ordersSnap.docs.length}");

      for (var orderDoc in ordersSnap.docs) {
        final feedbackSnap = await orderDoc.reference
            .collection('feedback')
            .get();

        if (feedbackSnap.docs.isEmpty) {
          print("User: ${userDoc.id} - No feedback in order ${orderDoc.id}");
          continue;
        }

        for (var fbDoc in feedbackSnap.docs) {
          final fbData = fbDoc.data();
          fbData['userId'] = userDoc.id;
          fbData['orderId'] = orderDoc.id;
          setState(() {
            _allFeedback.add(fbData);
          });
          print(
            "User: ${userDoc.id} - Order: ${orderDoc.id} - Feedback: ${fbData['comment']} (Rating: ${fbData['rating']})",
          );
        }
      }
    }

    print("Total feedback entries fetched: ${_allFeedback.length}");
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Feedback Reports')),
      body: _allFeedback.isEmpty
          ? const Center(child: Text('No feedback found.'))
          : ListView.builder(
              itemCount: _allFeedback.length,
              itemBuilder: (context, index) {
                final feedback = _allFeedback[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text("User: ${feedback['userId']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order ID: ${feedback['orderId']}"),
                        const SizedBox(height: 4),
                        Text(
                          "Feedback: ${feedback['comment'] ?? 'No comment'}",
                        ),
                        Text("Rating: ${feedback['rating'] ?? 'N/A'}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
