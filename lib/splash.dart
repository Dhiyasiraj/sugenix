import 'package:flutter/material.dart';
import 'package:sugenix/signin.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Signup())
      );
    });
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [const Color(0xFF0c4556), Colors.white],
          ),
        ),
        child: Center(child: Text("sugenix", style: TextStyle())),
      ),
    );
  }
}
