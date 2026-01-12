import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_aub/auth/login_screen.dart';
import 'package:flutter_project_aub/auth/register_screen.dart';
import 'package:flutter_project_aub/firebase_options.dart';
import 'package:flutter_project_aub/layout/add_task_screen.dart';
import 'package:flutter_project_aub/layout/calendar_screen.dart';
import 'package:flutter_project_aub/layout/setting_screen.dart';
import 'package:flutter_project_aub/layout/welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/auth_gate.dart';
import 'layout/complete_profile_screen.dart';
import 'layout/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: AuthGate(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        "/complete-profile": (context) => const CompleteProfileScreen(),
        '/setting': (context) => const SettingsScreen(),
        '/calendar': (context) => CalendarScreen(),
        '/addTask' : (context) => AddTaskScreen(),
      },
    );
  }
}
