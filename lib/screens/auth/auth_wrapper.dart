// screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:petzy/providers/auth_provider.dart';
import 'package:petzy/screens/auth/login_screen.dart';
import 'package:petzy/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.user == null) {
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
  }
}