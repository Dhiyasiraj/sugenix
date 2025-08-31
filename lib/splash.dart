import 'package:flutter/material.dart';
import 'package:sugenix/signin.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft, // Start from top-left
            radius: 0.7,
            colors: [
              Color(0xFF0C4556),
              Colors.white,
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Add second gradient at bottom-right
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomRight,
                  radius: 0.7,
                  colors: [
                    Color(0x800C4556), // 50% opacity
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
            // Center content
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cross logo
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C4556),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C4556),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "SUGENIX",
                    style: TextStyle(
                      color: Color(0xFF0C4556),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
