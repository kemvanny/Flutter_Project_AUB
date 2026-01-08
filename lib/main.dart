import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_aub/bottomnavigation/homepage_sceen.dart';
import 'package:flutter_project_aub/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

bool isFirebaseInitialized() {
  try {
    Firebase.app();
    return true;
  } catch (e) {
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (isFirebaseInitialized()) {
    debugPrint("Firebase already initialized");
  } else {
    debugPrint("Firebase not initialized");
  }

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
      // initialRoute: '/welcome',
      // routes: {
      //   '/': (context) => const HomeScreen(),
      //   '/welcome': (context) => const WelcomeScreen(),
      //   '/register': (context) => const RegisterScreen(),
      //   '/login': (context) => const LoginScreen(),
      // },
      home: HomepageSceen(),
    );
  }
}
