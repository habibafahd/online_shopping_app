import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  DateTime? _selectedDate;

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? dateFilterText = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
            tooltip: 'Select Date',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collectionGroup('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orderDocs = snapshot.data!.docs;

          // Filter orders by selected date
          final filteredOrders = _selectedDate != null
              ? orderDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['date'] == null) return false;
                  final Timestamp ts = data['date'];
                  final orderDate = ts.toDate();
                  return orderDate.year == _selectedDate!.year &&
                      orderDate.month == _selectedDate!.month &&
                      orderDate.day == _selectedDate!.day;
                }).toList()
              : orderDocs;

          if (filteredOrders.isEmpty) {
            return Center(
              child: Text(
                _selectedDate != null
                    ? 'No orders found on $dateFilterText'
                    : 'No orders found',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final orderDoc = filteredOrders[index];
              final data = orderDoc.data() as Map<String, dynamic>;
              final pathSegments = orderDoc.reference.path.split('/');
              final userId = pathSegments[1];
              final orderId = pathSegments[3];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: Text('Order ID: $orderId'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User ID: $userId'),
                      Text('Address: ${data['address'] ?? 'N/A'}'),
                      Text('Phone: ${data['phone'] ?? 'N/A'}'),
                      Text('Total: \$${data['total']?.toString() ?? '0.00'}'),
                      if (data['date'] != null)
                        Text(
                          (data['date'] as Timestamp)
                              .toDate()
                              .toLocal()
                              .toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      Text('Items: ${data['items']?.join(', ') ?? 'No items'}'),
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
