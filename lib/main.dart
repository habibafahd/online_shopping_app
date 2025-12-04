import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';

// Manually added Firebase configuration for web
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyAMj4hBG08a2_OIR6dWtII22GOXmZKIW-8",
  authDomain: "online-shopping-app-7595d.firebaseapp.com",
  projectId: "online-shopping-app-7595d",
  storageBucket: "online-shopping-app-7595d.appspot.com",
  messagingSenderId: "561760250720",
  appId: "1:561760250720:web:70ddf91960f1c808fa8c05",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Shopping App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), // Launch LoginScreen first
      debugShowCheckedModeBanner: false, // <-- removes the debug banner
    );
  }
}
