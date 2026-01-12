import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../layout/complete_profile_screen.dart';
import '../layout/home_screen.dart';
import '../layout/welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // NOT LOGGED IN
        if (!snapshot.hasData) {
          return const WelcomeScreen();
        }

        final uid = snapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Firestore doc missing → treat as new user or deleted account
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              // Sign out user if doc doesn't exist
              FirebaseAuth.instance.signOut();
              return const WelcomeScreen();
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>?;
            final profileCompleted = data?['profileCompleted'] == true;

            if (profileCompleted) {
              return const HomeScreen();
            } else {
              return const CompleteProfileScreen();
            }
          },
        );

      },
    );
  }
}
