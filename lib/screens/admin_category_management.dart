import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCategoryManagement extends StatefulWidget {
  const AdminCategoryManagement({super.key});

  @override
  State<AdminCategoryManagement> createState() =>
      _AdminCategoryManagementState();
}

class _AdminCategoryManagementState extends State<AdminCategoryManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Show dialog to add or edit a category
  void _showCategoryForm({DocumentSnapshot? categoryDoc}) {
    final nameController = TextEditingController(
      text: categoryDoc != null
          ? (categoryDoc.data() as Map<String, dynamic>)['name']
          : '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(categoryDoc != null ? 'Edit Category' : 'Add Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category name is required')),
                );
                return;
              }

              if (categoryDoc != null) {
                // Update category
                await _firestore
                    .collection('categories')
                    .doc(categoryDoc.id)
                    .update({'name': name});
              } else {
                // Add new category
                await _firestore.collection('categories').add({'name': name});
              }

              Navigator.pop(context);
            },
            child: Text(categoryDoc != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  // Delete category
  void _deleteCategory(String docId) async {
    await _firestore.collection('categories').doc(docId).delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Category deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Category Management')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categoryDoc = categories[index];
              final categoryData = categoryDoc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(categoryData['name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          _showCategoryForm(categoryDoc: categoryDoc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCategory(categoryDoc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(),
        child: const Icon(Icons.add),
        tooltip: 'Add Category',
      ),
    );
  }
}
