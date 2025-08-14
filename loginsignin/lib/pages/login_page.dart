import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:loginsignin/components/my_button.dart';
import 'package:loginsignin/components/my_textfield.dart';
import 'package:loginsignin/components/square_tile.dart';
import 'package:loginsignin/pages/signup_page.dart';
import 'package:loginsignin/pages/home_page.dart';

// IMPORTANT: Change this to your LAN IP (works for Chrome/Android)
const String baseUrl = "http://192.168.0.109:8000/api";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController(); // email or username
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signUserIn() async {
    final loginId = usernameController.text.trim(); // can be email or username
    final password = passwordController.text.trim();

    if (loginId.isEmpty || password.isEmpty) {
      _showSnack('Please enter both Email/Username and Password');
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse("$baseUrl/login/");
      // Your Django login expects:
      // { "username": "<email or username>", "password": "..." }
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": loginId, "password": password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // SimpleJWT returns: access, refresh, and we added user info in serializer
        final access = data["access"];
        final refresh = data["refresh"];
        final user = data["user"];

        if (access != null && refresh != null) {
          // Save tokens for later (works on web too)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("access", access);
          await prefs.setString("refresh", refresh);
          await prefs.setString("username", user?["username"] ?? loginId);

          _showSnack("Login Successful ✅");

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(username: user?["username"] ?? loginId),
            ),
          );
        } else {
          _showSnack("Invalid server response.");
        }
      } else {
        // Try to read error from server
        String msg = "Invalid credentials ❌";
        try {
          final err = jsonDecode(res.body);
          msg = (err["detail"] ?? err["message"] ?? msg).toString();
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Icon(Icons.lock_outline_rounded,
                      size: 100, color: Colors.blueAccent),
                  const SizedBox(height: 30),
                  Text(
                    'Welcome back,\nYou\'ve been missed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Email or Username
                  MyTextField(
                    controller: usernameController,
                    hintText: 'Email or Username',
                    obscureText: false,
                  ),
                  const SizedBox(height: 15),

                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  isLoading
                      ? const CircularProgressIndicator()
                      : MyButton(onTap: signUserIn, buttonText: "Sign In"),

                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Expanded(
                          child: Divider(thickness: 0.5, color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Or continue with',
                            style: TextStyle(color: Colors.grey[700])),
                      ),
                      Expanded(
                          child: Divider(thickness: 0.5, color: Colors.grey[400])),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SquareTile(imagePath: 'lib/images/google.png'),
                      SizedBox(width: 25),
                      SquareTile(imagePath: 'lib/images/apple.png'),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Not a member?', style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUpPage()),
                          );
                        },
                        child: const Text(
                          'Register now',
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
      ),
    );
  }
}
