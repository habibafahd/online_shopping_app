import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import 'product_details_page.dart';

class ProductListPage extends StatefulWidget {
  final String categoryName;
  final List<Product> products;
  final Function(Product, String) onAddToCart;
  final Function(Widget) onOpenPage;
  final Widget homePage;

  const ProductListPage({
    super.key,
    required this.categoryName,
    required this.products,
    required this.onAddToCart,
    required this.onOpenPage,
    required this.homePage,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = "";
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Speech recognition error: ${error.errorMsg}'),
          ),
        );
      },
    );

    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  void _startListening() async {
    if (_isListening) return;
    bool available = await _speech.initialize();
    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _isListening = true);

    _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _searchController.text = result.recognizedWords;
          searchText = result.recognizedWords.trim().toLowerCase();
        });
      },
    );
  }

  void _stopListening() {
    _speech.stop();
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  Future<Product?> _fetchProductByBarcode(String barcode) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('products')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      final data = doc.data();
      return Product.fromMap(data as Map<String, dynamic>, doc.id);
    } catch (e) {
      print("Error fetching product by barcode: $e");
      return null;
    }
  }

  void _openBarcodeScanner() {
    widget.onOpenPage(
      Scaffold(
        appBar: AppBar(title: const Text('Scan Barcode')),
        body: _ManualBarcodeScanner(
          onCodeDetected: (scannedCode) async {
            if (!mounted) return;
            Navigator.pop(context); // close scanner
            final matchedProduct = await _fetchProductByBarcode(scannedCode);
            if (!mounted) return;

            if (matchedProduct != null) {
              widget.onOpenPage(
                ProductDetailsPage(
                  product: matchedProduct,
                  onAddToCart: widget.onAddToCart,
                  onBack: () => widget.onOpenPage(widget),
                ),
              );
            } else if (mounted) {
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
    final filteredProducts = widget.products.where((p) {
      return p.name.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return WillPopScope(
      onWillPop: () async {
        widget.onOpenPage(widget.homePage);
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Search + Voice + Scan
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
                        hintText: "Search in category...",
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (!mounted) return;
                        setState(() {
                          searchText = value.trim().toLowerCase();
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : Colors.grey[700],
                    ),
                    onPressed: _isListening ? _stopListening : _startListening,
                    tooltip: 'Voice Search',
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _openBarcodeScanner,
                    tooltip: 'Scan Barcode',
                  ),
                ],
              ),
            ),
            if (_isListening)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mic, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text(
                      'Listening...',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _stopListening,
                      child: const Text('Stop'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return GestureDetector(
                    onTap: () {
                      widget.onOpenPage(
                        ProductDetailsPage(
                          product: product,
                          onAddToCart: widget.onAddToCart,
                          onBack: () => widget.onOpenPage(widget),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(product.icon, size: 60, color: Colors.blue),
                          const SizedBox(height: 10),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "\$${product.price}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
  String scannedCode = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            final code = capture.barcodes.first.rawValue;
            if (code != null && scannedCode.isEmpty) {
              setState(() => scannedCode = code);
            }
          },
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              onPressed: scannedCode.isEmpty
                  ? null
                  : () => widget.onCodeDetected(scannedCode),
              child: const Text('Scan'),
            ),
          ),
        ),
      ],
    );
  }
}
