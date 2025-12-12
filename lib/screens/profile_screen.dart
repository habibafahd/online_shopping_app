import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String gender = "Male";
  DateTime birthday = DateTime(2000, 1, 1);
  String phone = "";
  String username = "@username";

  final AuthService auth = AuthService();
  final _firestore = FirebaseFirestore.instance;
  late String userId;

  @override
  void initState() {
    super.initState();
    final uid = auth.currentUserId();
    final email = auth.currentUserEmail();
    if (uid != null && email != null) {
      userId = uid;
      username = email.split('@')[0]; // username from email
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          phone = data['phone'] ?? '';
          gender = data['gender'] ?? 'Male';
          birthday = (data['birthday'] as Timestamp?)?.toDate() ?? birthday;
          // username stays as email prefix
        });
      } else {
        // create default document
        await _firestore.collection('users').doc(userId).set({
          'phone': phone,
          'gender': gender,
          'birthday': Timestamp.fromDate(birthday),
          'username': username, // from email
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _updateUserData() async {
    if (userId.isEmpty) return; // safety check
    await _firestore.collection('users').doc(userId).set({
      'phone': phone,
      'gender': gender,
      'birthday': Timestamp.fromDate(birthday),
      'username': username,
    }, SetOptions(merge: true));
  }

  Future<void> pickBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthday,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != birthday) {
      setState(() => birthday = picked);
      await _updateUserData(); // save immediately
    }
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
            onPressed: () async {
              setState(() => phone = controller.text);
              await _updateUserData();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void logout() async {
    await auth.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
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
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "@$username",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.male, color: Colors.blue),
              title: const Text(
                "Gender",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(gender),
              trailing: const Icon(Icons.edit),
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
                          onChanged: (String? val) async {
                            if (val != null) {
                              setState(() => gender = val);
                              await _updateUserData();
                              Navigator.pop(context);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cake, color: Colors.blue),
              title: const Text(
                "Birthday",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${birthday.toLocal()}".split(' ')[0]),
              trailing: const Icon(Icons.edit),
              onTap: pickBirthday,
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text(
                "Phone",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(phone),
              trailing: const Icon(Icons.edit),
              onTap: editPhone,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
