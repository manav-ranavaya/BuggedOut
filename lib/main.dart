import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _greeting;

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _greeting = "Welcome, $username!";
      });
    } else {
      setState(() {
        _greeting = "Please enter both username and password.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('PestGuard',
                  style: TextStyle(fontSize: 30, color: Colors.green)),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleLogin,
                child: Text('Login'),
              ),
              const SizedBox(height: 20),
              if (_greeting != null)
                Text(
                  _greeting!,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                )
            ],
          ),
        ),
      ),
    );
  }
}