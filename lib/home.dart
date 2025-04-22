import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key, required this.username});
  final String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Image.asset('assets/images/bg.png', fit: BoxFit.fill)),
        Center(
          child: Container(
              color: Colors.black87,
              padding: EdgeInsets.all(20),
              child: Text(
                'Hello $username',
                style: TextStyle(fontSize: 30, color: Colors.white),
              )),
        )
      ]),
    );
  }
}