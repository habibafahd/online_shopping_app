import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DateTime birthday = DateTime(2000, 1, 1);
  String username = "@username";

  final AuthService auth = AuthService();
  final ProfileService profileService = ProfileService();
  late String userId;
  final String birthdayId = "mainBirthday"; // only one birthday per user

  @override
  void initState() {
    super.initState();
    final uid = auth.currentUserId();
    final email = auth.currentUserEmail();
    if (uid != null && email != null) {
      userId = uid;
      username = email.split('@')[0];
      _loadBirthday();
    } else {
      print("User not logged in!");
    }
  }

  Future<void> _loadBirthday() async {
    final loadedBirthday = await profileService.loadBirthday(
      userId: userId,
      birthdayId: birthdayId,
    );
    if (loadedBirthday != null) {
      setState(() => birthday = loadedBirthday);
    } else {
      print("No birthday found yet for $userId");
    }
  }

  Future<void> _updateBirthday(DateTime newBirthday) async {
    await profileService.addBirthday(
      userId: userId,
      birthdayId: birthdayId,
      date: newBirthday,
    );
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
      await _updateBirthday(picked); // save immediately
    }
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
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
              leading: const Icon(Icons.cake, color: Colors.blue),
              title: const Text(
                "Birthday",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${birthday.toLocal()}".split(' ')[0]),
              trailing: const Icon(Icons.edit),
              onTap: pickBirthday,
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
