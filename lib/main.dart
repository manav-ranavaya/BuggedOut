import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup.dart';
import 'MainPage.dart';

void main() {
  runApp(BuggedOutApp());
}

class BuggedOutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuggedOut 🐛',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginPage(), // <- Start from LoginPage
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameOrEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _message;

  Future<void> _handleLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedUsername = prefs.getString('name');
    final savedPassword = prefs.getString('password');

    final entered = _usernameOrEmailController.text.trim();
    final enteredPassword = _passwordController.text;

    if ((entered == savedEmail || entered == savedUsername) && enteredPassword == savedPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome, $savedUsername!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(username: savedUsername ?? "User"),
        ),
      );
    } else {
      setState(() {
        _message = "Invalid credentials. Try again.";
      });

      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _message = null;
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
        width: 400,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('BuggedOut 🐛', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 20),
              TextField(
                controller: _usernameOrEmailController,
                decoration: InputDecoration(
                  labelText: 'Email or Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                child: Text('Login'),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp()),
                  );
                },
                child: Text("Don't have an account? Sign up"),
              ),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _message!,
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
