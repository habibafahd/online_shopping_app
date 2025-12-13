import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _rememberMeKey = 'remember_me';
  static const String _rememberedEmailKey = 'remembered_email';
  static const String _rememberedPasswordKey = 'remembered_password';

  // Get current user ID
  String? currentUserId() => _auth.currentUser?.uid;

  // Get current user email
  String? currentUserEmail() => _auth.currentUser?.email;

  // Sign up
  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Sign Up Error: $e");
      return null;
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
      print("Login Error: $e");
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Reset Password Error: $e");
    }
  }

  // Remember Me - Save email and password
  Future<void> saveRememberMeData(String email, String password, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool(_rememberMeKey, true);
      await prefs.setString(_rememberedEmailKey, email);
      // Encode password with base64 for basic obfuscation
      final encodedPassword = base64Encode(utf8.encode(password));
      await prefs.setString(_rememberedPasswordKey, encodedPassword);
    } else {
      await prefs.setBool(_rememberMeKey, false);
      await prefs.remove(_rememberedEmailKey);
      await prefs.remove(_rememberedPasswordKey);
    }
  }

  // Remember Me - Load email
  Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    if (rememberMe) {
      return prefs.getString(_rememberedEmailKey);
    }
    return null;
  }

  // Remember Me - Load password
  Future<String?> getRememberedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    if (rememberMe) {
      final encodedPassword = prefs.getString(_rememberedPasswordKey);
      if (encodedPassword != null) {
        try {
          // Decode password from base64
          return utf8.decode(base64Decode(encodedPassword));
        } catch (e) {
          print("Error decoding password: $e");
          return null;
        }
      }
    }
    return null;
  }

  // Remember Me - Check if remember me is enabled
  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  // Clear Remember Me data
  Future<void> clearRememberMeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, false);
    await prefs.remove(_rememberedEmailKey);
    await prefs.remove(_rememberedPasswordKey);
  }
}
