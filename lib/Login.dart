import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 50,right: 50,top: 68, bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 90,),
            Text(
              'Welcome Back',
              style: TextStyle(
                color: Colors.black,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 60),

            // Email TextField
            TextField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                hintText: "Email",
                suffixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 20),

            // Password TextField
            TextField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                hintText: "Password",
                suffixIcon: Icon(Icons.lock), // Replaced with lock icon
              ),
              obscureText: true, // To mask the password text
            ),
            SizedBox(height: 20),

            // Login Button
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(12, 69, 86, 72),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Forgot Password Text
            Text(
              'Forgot password',
              style: TextStyle(
                color: Color.fromRGBO(12, 69, 86, 72),
              ),
            ),
            SizedBox(height: 200),

            // Sign Up Text
            Text(
              "Don't have an account? Join us",
              style: TextStyle(
                color: Color.fromRGBO(12, 69, 86, 72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
