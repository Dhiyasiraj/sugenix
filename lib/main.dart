import 'package:flutter/material.dart';
import 'package:sugenix/Login.dart';
import 'package:sugenix/forgetpass.dart';
import 'package:sugenix/menu.dart';
import 'package:sugenix/profile.dart';
import 'package:sugenix/record.dart';
import 'package:sugenix/signin.dart';
import 'package:sugenix/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
  return MaterialApp(debugShowCheckedModeBanner: false, home: Signup());
  }
}
