import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/product.dart';

class AdminReports extends StatefulWidget {
  const AdminReports({super.key});

  @override
  State<AdminReports> createState() => _AdminReportsState();
}

class _AdminReportsState extends State<AdminReports> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Reports')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Selected date: $formattedDate',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Pick Date'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getTransactionsWithFeedback(formattedDate),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transactions = snapshot.data!;
                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('No transactions found for this date.'),
                  );
                }

                // Count product sales for chart
                final Map<String, int> productSales = {};
                for (var t in transactions) {
                  final List products = t['products'] ?? [];
                  for (var p in products) {
                    final name = p['name'] ?? 'Unknown';
                    final stock =
                        (p['stock'] ?? 1) as num; // Firestore may return num
                    productSales[name] =
                        (productSales[name] ?? 0) + stock.toInt();
                  }
                }

                return ListView(
                  children: [
                    // ---------------- Transaction List ----------------
                    ...transactions.map((transactionData) {
                      final List products = transactionData['products'] ?? [];
                      final productList = products
                          .map(
                            (p) => "${p['name']} x${(p['stock'] ?? 0).toInt()}",
                          )
                          .join(", ");

                      final feedback = transactionData['feedback'] ?? {};
                      final rating = (feedback['rating'] ?? 'N/A').toString();
                      final comment = feedback['comment'] ?? 'No feedback';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            transactionData['userEmail'] ?? 'Unknown User',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(productList),
                              const SizedBox(height: 4),
                              Text('Feedback: $comment (Rating: $rating)'),
                            ],
                          ),
                          trailing: Text("\$${transactionData['total'] ?? 0}"),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 16),

                    // ---------------- Best Selling Products Chart ----------------
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 300,
                        child: SfCartesianChart(
                          title: ChartTitle(text: 'Best Selling Products'),
                          primaryXAxis: CategoryAxis(),
                          primaryYAxis: NumericAxis(),
                          series: <CartesianSeries>[
                            ColumnSeries<MapEntry<String, int>, String>(
                              dataSource: productSales.entries.toList(),
                              xValueMapper: (entry, _) => entry.key,
                              yValueMapper: (entry, _) => entry.value,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Fetch transactions and attach feedback
  Future<List<Map<String, dynamic>>> _getTransactionsWithFeedback(
    String date,
  ) async {
    final List<Map<String, dynamic>> allTransactions = [];

    final usersSnap = await _firestore.collection('users').get();
    for (var userDoc in usersSnap.docs) {
      final ordersSnap = await userDoc.reference
          .collection('orders')
          .where('date', isEqualTo: date)
          .get();

      for (var orderDoc in ordersSnap.docs) {
        final orderData = orderDoc.data();

        // Attach feedback if exists
        final feedbackSnap = await orderDoc.reference
            .collection('feedback')
            .get();
        if (feedbackSnap.docs.isNotEmpty) {
          final feedbackData = feedbackSnap.docs.first.data();
          orderData['feedback'] = feedbackData;
        }

        // Attach user email
        orderData['userEmail'] = userDoc['email'] ?? 'Unknown';
        allTransactions.add(orderData);
      }
    }

    return allTransactions;
  }
}
