import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../screens/product_details_page.dart';

class HomeScreen extends StatefulWidget {
  final Function(Product, String) onAddToCart;
  final Function(Widget) onOpenPage;
  final Function(String) onCategoryTap;

  const HomeScreen({
    super.key,
    required this.onAddToCart,
    required this.onOpenPage,
    required this.onCategoryTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  String? lastScannedBarcode;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.checkroom, "name": "T-Shirt"},
    {"icon": Icons.shopping_bag, "name": "Pants"},
    {"icon": Icons.ac_unit, "name": "Jacket"},
    {"icon": Icons.ac_unit, "name": "Dress"},
  ];

  // ---------------- Voice Search ----------------
  void _startListening() async {
    if (!_isListening) {
      final available = await _speech.initialize();
      if (!available) return;

      setState(() => _isListening = true);

      _speech.listen(
        onResult: (result) {
          setState(() {
            _searchController.text = result.recognizedWords;
            searchText = result.recognizedWords.toLowerCase().trim();
          });
        },
      );
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // ---------------- Firebase Barcode Lookup ----------------
  Future<Product?> getProductByBarcode(String barcode) async {
    final query = await FirebaseFirestore.instance
        .collection('products')
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    final data = doc.data();
    return Product.fromMap(data as Map<String, dynamic>, doc.id);
  }

  // ---------------- Barcode Scanner ----------------
  void _openBarcodeScanner() {
    widget.onOpenPage(
      Scaffold(
        appBar: AppBar(title: const Text('Scan Barcode')),
        body: _ManualBarcodeScanner(
          onCodeDetected: (scannedCode) async {
            final matchedProduct = await getProductByBarcode(scannedCode);

            if (matchedProduct != null) {
              // Close scanner first
              Navigator.of(context).pop();

              // Then open product details
              widget.onOpenPage(
                ProductDetailsPage(
                  product: matchedProduct,
                  onAddToCart: widget.onAddToCart,
                  onBack: () => widget.onOpenPage(
                    HomeScreen(
                      onAddToCart: widget.onAddToCart,
                      onOpenPage: widget.onOpenPage,
                      onCategoryTap: widget.onCategoryTap,
                    ),
                  ),
                ),
              );

              setState(() {
                lastScannedBarcode = scannedCode;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product not found')),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = categories.where(
      (item) =>
          searchText.isEmpty ||
          item["name"].toString().toLowerCase().contains(searchText),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search products...",
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value.toLowerCase().trim();
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.grey[700],
                  ),
                  onPressed: _startListening,
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _openBarcodeScanner,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          if (lastScannedBarcode != null)
            Text(
              'Last scanned barcode: $lastScannedBarcode',
              style: const TextStyle(fontSize: 14, color: Colors.green),
            ),

          const SizedBox(height: 20),
          const Text(
            "Categories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          Expanded(
            child: ListView(
              children: filteredCategories.map((item) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Icon(item["icon"], size: 40, color: Colors.blue),
                    title: Text(item["name"]),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => widget.onCategoryTap(item["name"]),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Manual Barcode Scanner ----------------
class _ManualBarcodeScanner extends StatefulWidget {
  final Function(String) onCodeDetected;
  const _ManualBarcodeScanner({required this.onCodeDetected});

  @override
  State<_ManualBarcodeScanner> createState() => _ManualBarcodeScannerState();
}

class _ManualBarcodeScannerState extends State<_ManualBarcodeScanner> {
  final MobileScannerController _controller = MobileScannerController();
  String? _scannedCode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            final code = capture.barcodes.first.rawValue;
            if (code != null && _scannedCode == null) {
              setState(() => _scannedCode = code);
            }
          },
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              onPressed: _scannedCode == null
                  ? null
                  : () => widget.onCodeDetected(_scannedCode!),
              child: const Text('Scan'),
            ),
          ),
        ),
      ],
    );
  }
}
