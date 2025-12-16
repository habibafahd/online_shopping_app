import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminBestSellingPage extends StatefulWidget {
  const AdminBestSellingPage({super.key});

  @override
  State<AdminBestSellingPage> createState() => _AdminBestSellingPageState();
}

class _AdminBestSellingPageState extends State<AdminBestSellingPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Map<String, int> productCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBestSellingProducts();
  }

  Future<void> _fetchBestSellingProducts() async {
    try {
      final orderDocs = await _db.collectionGroup('orders').get();
      Map<String, int> counts = {};

      for (var doc in orderDocs.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>?;

        if (items != null) {
          for (var item in items) {
            if (item is Map<String, dynamic>) {
              final name = item['name'] as String? ?? 'Unknown';
              final quantity = item['quantity'] as int? ?? 1;
              counts[name] = (counts[name] ?? 0) + quantity;
            } else if (item is String) {
              // fallback if stored as string
              counts[item] = (counts[item] ?? 0) + 1;
            }
          }
        }
      }

      setState(() {
        productCounts = counts;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching products: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Best Selling Products')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (productCounts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Best Selling Products')),
        body: Center(child: Text('No orders found')),
      );
    }

    final sortedProducts = productCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topProducts = sortedProducts.take(10).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Best Selling Products')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (topProducts.first.value * 1.2).toDouble(),
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    int index = value.toInt();
                    if (index < topProducts.length) {
                      return Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          topProducts[index].key,
                          style: TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(topProducts.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: topProducts[index].value.toDouble(),
                    color: Colors.blue,
                    width: 20,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
