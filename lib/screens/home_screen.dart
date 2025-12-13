import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_list_page.dart';

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
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.checkroom, "name": "T-Shirt"},
    {"icon": Icons.shopping_bag, "name": "Pants"},
    {"icon": Icons.ac_unit, "name": "Jacket"},
    {"icon": Icons.ac_unit, "name": "Dress"},
  ];

  @override
  void initState() {
    super.initState();
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
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech recognition error: ${error.errorMsg}')),
        );
      },
    );
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _searchController.text = result.recognizedWords;
              searchText = result.recognizedWords.trim().toLowerCase();
            });
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
    } else {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _showImageSearchDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _showImageSearchDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  void _showImageSearchDialog() {
    if (_selectedImage == null) return;
    
    // Show dialog with the image and search options
    // In a real app, you would use ML/vision API to identify the product
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(
              _selectedImage!,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            const Text(
              'Image search feature would use ML to identify products. For now, you can search manually.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedImage = null;
              });
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // In a real implementation, this would trigger ML-based search
              // For now, we'll just clear the image
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image search would identify products here'),
                ),
              );
              setState(() {
                _selectedImage = null;
              });
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _handleImageSearch() {
    if (_selectedImage != null) {
      _showImageSearchDialog();
    } else {
      // Show dialog to choose image source
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> categoryWidgets = categories
        .where(
          (item) =>
              searchText.isEmpty ||
              item["name"].toString().toLowerCase().contains(searchText),
        )
        .map<Widget>((item) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(item["icon"], size: 40, color: Colors.blue),
              title: Text(
                item["name"],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => widget.onCategoryTap(item["name"]),
            ),
          );
        })
        .toList();

    if (searchText.isNotEmpty && categoryWidgets.isEmpty) {
      categoryWidgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              "No products found",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

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
                        searchText = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                // Voice search button
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.grey[700],
                  ),
                  onPressed: _startListening,
                  tooltip: 'Voice Search',
                ),
                // Image search button
                IconButton(
                  icon: Icon(
                    _selectedImage != null ? Icons.image : Icons.image_outlined,
                    color: _selectedImage != null ? Colors.blue : Colors.grey[700],
                  ),
                  onPressed: _handleImageSearch,
                  tooltip: 'Image Search',
                ),
              ],
            ),
          ),
          // Show selected image preview if available
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          // Show listening indicator
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
          const SizedBox(height: 20),
          const Text(
            "Categories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Expanded(child: ListView(children: categoryWidgets)),
        ],
      ),
    );
  }
}
