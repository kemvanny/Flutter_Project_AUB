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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _obscurePassword = true;
  bool _isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ================= EMAIL LOGIN =================
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Attempt to sign in
      final userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw FirebaseAuthException(code: 'no-uid');

      // Check if Firestore user exists
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!doc.exists) {
        // Auto-create Firestore record for this user
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fullName': '',
          'email': emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home");

    } on FirebaseAuthException catch (e) {
      debugPrint("AUTH ERROR CODE: ${e.code}");
      debugPrint("AUTH ERROR MESSAGE: ${e.message}");

      switch (e.code) {
        case 'user-not-found':
          _showError("No account found with this email. Maybe use Google Sign-In?");
          break;
        case 'wrong-password':
          _showError("Incorrect password. Try resetting it if you forgot.");
          break;
        case 'invalid-email':
          _showError("Invalid email address");
          break;
        case 'user-disabled':
          _showError("This account has been disabled");
          break;
        case 'no-uid':
          _showError("Login failed: missing UID");
          break;
        case 'account-exists-with-different-credential':
          _showError("This email is linked with Google. Use Google Sign-In.");
          break;
        default:
          _showError("Login failed: ${e.message}");
      }

    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  // ================= GOOGLE LOGIN =================
  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home");
    } catch (_) {
      _showError("Google Sign-In failed");
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> _forgotPassword() async {
    final resetEmailController = TextEditingController(
      text: emailController.text.trim(),
    );

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Reset Password"),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Enter your email",
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty) {
                  _showError("Email cannot be empty");
                  return;
                }

                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: email);

                  if (!mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password reset email sent"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (_) {
                  _showError("Failed to send reset email");
                }
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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

  // ================= UI =================
  Widget _animatedBackground() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1E1B4B),
                Color(0xFF7C7AED),
                Color(0xFFA5B4FC)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              _circle(120, 60 + 50 * sin(_controller.value * 2 * pi), 240),
              _circle(420 + 40 * cos(_controller.value * 2 * pi), 260, 300),
              _circle(200, -140 + 60 * sin(_controller.value * 2 * pi), 190),
            ],
          ),
        );
      },
    );
  }

  Widget _circle(double top, double left, double size) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _content() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _loginCard(),
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
            border:
            Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 30),

                _input("Email", Icons.email_outlined,
                    controller: emailController),
                const SizedBox(height: 18),

                _input("Password", Icons.lock_outline,
                    isPassword: true, controller: passwordController),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _loginButton(),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: _signInWithGoogle,
                        child: _socialButton(
                            'assets/images/google.png')),
                    const SizedBox(width: 20),
                    _socialButton('assets/images/facebook.png'),
                  ],
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ",
                        style: TextStyle(color: Colors.white)),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, "/register"),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.bold),
                      ),
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

  Widget _input(String hint, IconData icon,
      {bool isPassword = false, TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      validator: (value) {
        if (value == null || value.isEmpty) return "$hint is required";
        if (hint == "Email" &&
            !RegExp(r'^[\w-]+@([\w-]+\.)+[a-zA-Z]{2,7}$')
                .hasMatch(value)) {
          return "Invalid email";
        }
        if (hint == "Password" && value.length < 6) {
          return "Minimum 6 characters";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.25),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithEmail,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Sign In"),
      ),
    );
  }

  Widget _socialButton(String asset) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Image.asset(asset, height: 28),
    );
  }
}
