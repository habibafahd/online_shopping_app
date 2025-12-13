import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'main_screen.dart';
import 'admin_dashboard.dart'; // <-- Import your admin page

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final rememberedEmail = await _auth.getRememberedEmail();
    final rememberedPassword = await _auth.getRememberedPassword();
    final isRememberMeEnabled = await _auth.isRememberMeEnabled();

    setState(() {
      if (rememberedEmail != null) {
        _emailController.text = rememberedEmail;
      }
      if (rememberedPassword != null) {
        _passwordController.text = rememberedPassword;
      }
      _rememberMe = isRememberMeEnabled;
      _isLoading = false;
    });
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // --- Normal login via Firebase ---
      final user = await _auth.login(email, password);
      if (user != null) {
        // Save remember me data
        await _auth.saveRememberMeData(email, password, _rememberMe);

        // --- Check if admin ---
        if (user.email == "admin_user@gmail.com" && password == "admin123") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Check email/password.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login error: $e')));
    }
  }

  void _resetPassword() async {
    await _auth.resetPassword(_emailController.text.trim());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Password reset email sent.')));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) async {
                    setState(() => _rememberMe = value!);
                    if (!value!) {
                      await _auth.clearRememberMeData();
                    }
                  },
                ),
                const Text('Remember me'),
              ],
            ),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            TextButton(
              onPressed: _resetPassword,
              child: const Text('Forgot Password?'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
