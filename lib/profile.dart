import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(184, 101, 160, 179),
                  Color.fromARGB(255, 255, 255, 255),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 30, right: 30),),
           Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 110),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Profile", style: TextStyle(fontSize: 24)),
                ),
                SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    "personal Information",
                    style: TextStyle(fontSize: 19),
                  ),
                ),
                SizedBox(height: 50),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText:" Enter your full name" ,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Contact number',
                    hintText: "xxx-xxxx-xxx",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: "DD/MM/YYYY",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Location',
                    hintText: "Add detailes",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
                
        ],
      ),
    );
  }
}