import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? currentUserId() => _auth.currentUser?.uid;

  // Sign up
  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception("Sign Up Error: $e");
    }
  }

  // Login
  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception("Login Error: $e");
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
