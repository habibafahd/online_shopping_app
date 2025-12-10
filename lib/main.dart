import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if a user is already logged in
    final User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'Online Shopping App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // If user is logged in → go straight to HomeScreen
      // If not → show LoginScreen
      home: user == null ? LoginScreen() : HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
