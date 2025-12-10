import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String gender = "";
  DateTime birthday = DateTime.now();
  String email = "";
  String phone = "";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    final userId = AuthService().currentUserId();
    final profile = await UserService().getUserProfile(userId);
    setState(() {
      gender = profile.gender;
      birthday = profile.birthday;
      email = profile.email;
      phone = profile.phone;
    });
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
      final userId = AuthService().currentUserId();
      await UserService().updateUserProfile(userId, birthday: birthday);
    }
  }

  void editField(String field, String currentValue) {
    TextEditingController controller = TextEditingController(
      text: currentValue,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final userId = AuthService().currentUserId();
              if (field == "Email") {
                await UserService().updateUserProfile(
                  userId,
                  email: controller.text,
                );
                setState(() => email = controller.text);
              } else if (field == "Phone") {
                await UserService().updateUserProfile(
                  userId,
                  phone: controller.text,
                );
                setState(() => phone = controller.text);
              }
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileRow(
            icon: Icons.male,
            label: "Gender",
            value: gender,
            onTap: () {},
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
            onTap: () => editField("Email", email),
          ),
          ProfileRow(
            icon: Icons.phone,
            label: "Phone",
            value: phone,
            onTap: () => editField("Phone", phone),
          ),
        ],
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
