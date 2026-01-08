import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../layout/home_screen.dart';
import '../layout/welcome_screen.dart';

class AuthGate extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}