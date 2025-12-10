import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String gender = "Male";
  DateTime birthday = DateTime(2000, 1, 1);
  String email = "";
  String phone = "";

  final String? userId = AuthService().currentUserId();

  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (userId == null) return;

    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        email = data['email'] ?? '';
        phone = data['phone'] ?? '';
        gender = data['gender'] ?? 'Male';
        birthday = (data['birthday'] as Timestamp?)?.toDate() ?? birthday;
      });
    }
  }

  Future<void> _updateUserData() async {
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).set({
      'email': email,
      'phone': phone,
      'gender': gender,
      'birthday': birthday,
    }, SetOptions(merge: true));
  }

  Future<void> pickBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthday,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => birthday = picked);
      _updateUserData();
    }
  }

  void editEmail() {
    TextEditingController controller = TextEditingController(text: email);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Email"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() => email = controller.text);
              _updateUserData();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void editPhone() {
    TextEditingController controller = TextEditingController(text: phone);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Phone"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() => phone = controller.text);
              _updateUserData();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: const [
                  CircleAvatar(radius: 50, backgroundColor: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "Your Name",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text("@username", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ProfileRow(
              icon: Icons.male,
              label: "Gender",
              value: gender,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Select Gender"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: ["Male", "Female"].map((g) {
                        return RadioListTile(
                          value: g,
                          groupValue: gender,
                          title: Text(g),
                          onChanged: (String? val) {
                            setState(() => gender = val!);
                            _updateUserData();
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            ProfileRow(
              icon: Icons.cake,
              label: "Birthday",
              value: "${birthday.toLocal()}".split(' ')[0],
              onTap: pickBirthday,
            ),
            ProfileRow(
              icon: Icons.email,
              label: "Email",
              value: email,
              onTap: editEmail,
            ),
            ProfileRow(
              icon: Icons.phone,
              label: "Phone",
              value: phone,
              onTap: editPhone,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const ProfileRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit),
      onTap: onTap,
    );
  }
}
