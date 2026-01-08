import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ===== EMAIL/PASSWORD LOGIN =====
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final fullName = data['fullName'] ?? '';
          final email = data['email'] ?? '';
          // store user info locally or pass to HomeScreen
        }
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  // ===== GOOGLE LOGIN =====
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pushNamed(context, "/home");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Sign-In failed"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _animatedBackground(),
          _content(),
        ],
      ),
    );
  }

  Widget _animatedBackground() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF7C7AED), Color(0xFFA5B4FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              _circle(120, 60 + 50 * sin(_controller.value * 2 * pi), 240, Colors.white.withOpacity(0.08)),
              _circle(420 + 40 * cos(_controller.value * 2 * pi), 260, 300, Colors.white.withOpacity(0.06)),
              _circle(200, -140 + 60 * sin(_controller.value * 2 * pi), 190, Colors.white.withOpacity(0.07)),
            ],
          ),
        );
      },
    );
  }

  Widget _circle(double top, double left, double size, Color color) {
    return Positioned(
      top: top,
      left: left,
      child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    );
  }

  Widget _content() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(offset: Offset(0, 40 * (1 - value)), child: child),
              );
            },
            child: _loginCard(),
          ),
        ),
      ),
    );
  }

  Widget _loginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 40, offset: const Offset(0, 18))],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 10),
                Text("Welcome back", style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9))),
                const SizedBox(height: 30),
                _input("Email", Icons.email_outlined, controller: emailController),
                const SizedBox(height: 18),
                _input("Password", Icons.lock_outline, isPassword: true, controller: passwordController),
                const SizedBox(height: 32),
                _loginButton(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text("OR", style: TextStyle(color: Colors.white))),
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(onTap: _signInWithGoogle, child: _socialButton('assets/images/google.png')),
                    const SizedBox(width: 20),
                    GestureDetector(child: _socialButton('assets/images/facebook.png')),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: TextStyle(color: Colors.white.withOpacity(0.8))),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text("Sign Up", style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String hint, IconData icon, {bool isPassword = false, TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      validator: (value) {
        if (value == null || value.isEmpty) return "$hint cannot be empty";
        if (hint == "Email" && !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) return "Enter a valid email";
        if (hint == "Password" && value.length < 6) return "Password must be at least 6 characters";
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.25),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.white.withOpacity(0.35))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithEmail,
        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _socialButton(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Image.asset(assetPath, height: 28, width: 28),
    );
  }
}
