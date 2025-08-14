import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:loginsignin/components/my_button.dart';
import 'package:loginsignin/components/my_textfield.dart';
import 'package:loginsignin/components/square_tile.dart';
import 'login_page.dart';

// same base URL
const String baseUrl = "http://192.168.0.109:8000/api";

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUserUp() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnack('Please fill all required fields');
      return;
    }
    if (password != confirmPassword) {
      _showSnack('Passwords do not match');
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse("$baseUrl/register/");
      // Your Django register expects:
      // username, email, password, confirm_password, first_name, last_name
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "first_name": firstName,
          "last_name": lastName,
          "password": password,
          "confirm_password": confirmPassword,
        }),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        _showSnack("Registration Successful ✅");

        if (!mounted) return;
        // Option A: go to Login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );

        // Option B: Auto-login then go Home (uncomment if you prefer)
        // await _loginAfterRegister(usernameOrEmail: email, password: password);
      } else {
        String msg = "Registration failed";
        try {
          final err = jsonDecode(res.body);
          // Collect error messages from DRF
          msg = err is Map ? err.values.first.toString() : msg;
        } catch (_) {}
        _showSnack(msg);
      }
    } catch (e) {
      _showSnack("Network error: $e");
      if (kDebugMode) {
        print(e);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.person_add, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Create your account',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 25),

                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                MyTextField(
                  controller: firstNameController,
                  hintText: 'First Name (optional)',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                MyTextField(
                  controller: lastNameController,
                  hintText: 'Last Name (optional)',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 25),

                isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(onTap: signUserUp, buttonText: "Sign Up"),

                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SquareTile(imagePath: 'lib/images/google.png'),
                    SizedBox(width: 25),
                    SquareTile(imagePath: 'lib/images/apple.png'),
                  ],
                ),

                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
