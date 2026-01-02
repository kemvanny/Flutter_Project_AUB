import 'package:flutter/material.dart';
import 'package:flutter_project_aub/auth/login_screen.dart';
import 'package:flutter_project_aub/auth/register_screen.dart';
import 'package:flutter_project_aub/layout/welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'layout/home_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      initialRoute: '/welcome',
      routes: {
        '/': (context) => const HomeScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
