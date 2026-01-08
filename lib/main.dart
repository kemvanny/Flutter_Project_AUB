import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_aub/bottomnavigation/homepage_sceen.dart';
import 'package:flutter_project_aub/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD

bool isFirebaseInitialized() {
  try {
    Firebase.app();
    return true;
  } catch (e) {
    return false;
  }
}
=======
import 'layout/home_screen.dart';
>>>>>>> 28fbc038e59c1d6c0a1293dc29bd8d38bf5c6444

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
<<<<<<< HEAD
      // initialRoute: '/welcome',
      // routes: {
      //   '/': (context) => const HomeScreen(),
      //   '/welcome': (context) => const WelcomeScreen(),
      //   '/register': (context) => const RegisterScreen(),
      //   '/login': (context) => const LoginScreen(),
      // },
      home: HomepageSceen(),
=======
      home: const AuthGate(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
>>>>>>> 28fbc038e59c1d6c0a1293dc29bd8d38bf5c6444
    );
  }
}

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

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}

