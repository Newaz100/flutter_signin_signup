import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loginsignin/components/my_button.dart';
import 'package:loginsignin/components/my_textfield.dart';
import 'package:loginsignin/components/square_tile.dart';
import 'package:loginsignin/pages/signup_page.dart';
import 'package:loginsignin/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  // Function to log in
  Future<void> signUserIn() async {
    String email = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter both email and password");
      return;
    }

    setState(() => isLoading = true);

    try {
    var url = Uri.parse("http://192.168.0.109:8000/api/login/");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"username": email, "password": password}),

      );

      var data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        _showMessage("Login Successful ✅");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(username: email)),
        );
      } else {
        _showMessage(data["message"] ?? "Invalid credentials ❌");
      }
    } catch (e) {
      _showMessage("Error: $e");
    }

    setState(() => isLoading = false);
  }

  void _showMessage(String msg) {
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
                  const Icon(Icons.lock_outline_rounded, size: 100, color: Colors.blueAccent),
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
                  MyTextField(controller: usernameController, hintText: 'Email', obscureText: false),
                  const SizedBox(height: 15),
                  MyTextField(controller: passwordController, hintText: 'Password', obscureText: true),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.w500),
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
                      Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Or continue with', style: TextStyle(color: Colors.grey[700])),
                      ),
                      Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareTile(imagePath: 'lib/images/google.png'),
                      const SizedBox(width: 25),
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
                            MaterialPageRoute(builder: (context) => SignUpPage()),
                          );
                        },
                        child: const Text(
                          'Register now',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
