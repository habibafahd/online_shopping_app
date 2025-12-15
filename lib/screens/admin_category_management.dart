import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final CollectionReference _categoriesRef = FirebaseFirestore.instance
      .collection('categories');

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  // ------------------ Add/Edit Category ------------------
  void _showCategoryDialog({DocumentSnapshot? categoryDoc}) {
    if (categoryDoc != null) {
      _nameController.text = categoryDoc['name'];
    } else {
      _nameController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(categoryDoc == null ? 'Add Category' : 'Edit Category'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
            validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              final name = _nameController.text.trim();

              try {
                if (categoryDoc == null) {
                  // Add new category
                  await _categoriesRef.add({'name': name});
                } else {
                  // Edit existing category
                  await _categoriesRef.doc(categoryDoc.id).update({
                    'name': name,
                  });
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(categoryDoc == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  // ------------------ Delete Category ------------------
  void _deleteCategory(String id) async {
    try {
      await _categoriesRef.doc(id).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Category deleted')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _categoriesRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!.docs;

          if (categories.isEmpty) {
            return const Center(child: Text('No categories found'));
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final c = categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(c['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showCategoryDialog(categoryDoc: c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategory(c.id),
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
