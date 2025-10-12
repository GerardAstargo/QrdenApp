import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home_screen.dart';
import '../login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return user == null
        ? const LoginScreen() // User is not signed in
        : const HomeScreen(); // User is signed in
  }
}
