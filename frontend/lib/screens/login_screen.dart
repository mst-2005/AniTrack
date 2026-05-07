import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Standardized controllers for consistent data entry
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // 127.0.0.1 is the most stable local address for Chrome Web development
    final url = Uri.parse('http://127.0.0.1:5001/api/users/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"}, // Critical for Node.js parsing
        body: jsonEncode({
          // .trim() removes accidental spaces that cause 401 errors
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Save JWT and UserID to secure storage for session management
        // These keys must match your userRoutes.js response exactly
        await _storage.write(key: 'jwt', value: data['token']);
        await _storage.write(key: 'userId', value: data['userId']);

        if (mounted) {
          // Success: Route to the main responsive layout
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        // Handle 401 Unauthorized or 404 Not Found
        _showSnackBar(
          "Login Failed: Invalid Email or Password (Status ${response.statusCode})",
          Colors.blue[800]!,
        );
      }
    } catch (e) {
      // Catches 'Failed to fetch' CORS errors or Server Offline status
      _showSnackBar(
        "Connection Error: Is the server running on 5001?",
        Colors.redAccent,
      );
    }
  }

  // Standard helper for displaying feedback to the user
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020D14), // Midnight Blue theme
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 48),
                const SizedBox(height: 16),
                const Text(
                  "ANITRACK",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  "Your ultimate anime & TV tracker",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 40),
                _buildTextField(_emailController, "EMAIL", Icons.email_outlined),
                const SizedBox(height: 20),
                _buildTextField(_passwordController, "PASSWORD", Icons.lock_outline, obscure: true),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("LOG IN", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.cyanAccent),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
