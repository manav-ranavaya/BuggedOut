import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', nameController.text.trim());
      await prefs.setString('email', emailController.text.trim());
      await prefs.setString('password', passwordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign up successful!")),
      );

      Navigator.pop(context); // Go back to login page
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Container(
              width: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Create Account 🌾', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green)),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    decoration: _buildInputDecoration("Name"),
                    validator: (value) => value!.isEmpty ? "Please enter your name" : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: _buildInputDecoration("Email"),
                    validator: (value) => value!.isEmpty || !value.contains('@') ? "Enter a valid email" : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: _buildInputDecoration("Password"),
                    obscureText: true,
                    validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: _buildInputDecoration("Confirm Password"),
                    obscureText: true,
                    validator: (value) => value != passwordController.text ? "Passwords do not match" : null,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    child: Text("Sign Up"),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Already have an account? Log in"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
