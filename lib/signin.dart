import 'package:flutter/material.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(184, 117, 141, 148),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 110),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text("Sign In", style: TextStyle(fontSize: 24)),
                  ),
                  SizedBox(height: 70),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      "Your journey to smarter diabetes care starts here",
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  SizedBox(height: 50),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.visibility_off_outlined),
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(child: Text("User"), value: "user"),
                      DropdownMenuItem(child: Text("Admin"), value: "admin"),
                    ],
                    onChanged: (value) {},
                  ),
                  SizedBox(height: 50),
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (value) {},
                        activeColor: Colors.white,
                        checkColor: const Color.fromARGB(255, 85, 165, 215),
                      ),
                      Expanded(
                        child: Text(
                          "I agree to the Terms of Service and Privacy Policy",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      // Handle sign-in logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 24, 64, 89),
                      minimumSize: Size(double.infinity, 50), // Full width button
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 80),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: 19),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Login ",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 33, 88, 125),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
