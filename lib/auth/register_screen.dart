import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'uid': uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
      });

      Navigator.pushReplacementNamed(context, '/login');

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Auth error')),
      );

    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Firestore error')),
      );

    } catch (e, stack) {
      debugPrint("FLUTTER ERROR: $e");
      debugPrintStack(stackTrace: stack);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  // ================= UI =================
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
      builder: (_, __) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1E1B4B),
                Color(0xFF7C7AED),
                Color(0xFFA5B4FC),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              _circle(120, 80 + 40 * sin(_controller.value * 2 * pi), 230),
              _circle(420 + 50 * cos(_controller.value * 2 * pi), 260, 300),
              _circle(220, -140 + 60 * sin(_controller.value * 2 * pi), 190),
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
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.07),
        ),
      ),
    );
  }

  Widget _content() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _registerCard(),
        ),
      ),
    );
  }

  Widget _registerCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', height: 90),
                const SizedBox(height: 20),
                _input("Full Name", Icons.person, nameController),
                const SizedBox(height: 16),
                _input("Email", Icons.email, emailController),
                const SizedBox(height: 16),
                _input("Password", Icons.lock, passwordController,
                    isPassword: true),
                const SizedBox(height: 16),
                _input("Confirm Password", Icons.lock_outline,
                    confirmPasswordController,
                    isPassword: true, isConfirm: true),
                const SizedBox(height: 30),
                _registerButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
      String hint,
      IconData icon,
      TextEditingController controller, {
        bool isPassword = false,
        bool isConfirm = false,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword
          ? (isConfirm ? _obscureConfirm : _obscurePassword)
          : false,
      validator: (value) {
        if (value == null || value.isEmpty) return '$hint is required';
        if (hint == "Email" &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                .hasMatch(value)) {
          return 'Invalid email';
        }
        if (hint == "Password" && value.length < 6) {
          return 'Password must be 6+ characters';
        }
        if (hint == "Confirm Password" &&
            value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(isConfirm
              ? (_obscureConfirm
              ? Icons.visibility_off
              : Icons.visibility)
              : (_obscurePassword
              ? Icons.visibility_off
              : Icons.visibility)),
          onPressed: () {
            setState(() {
              isConfirm
                  ? _obscureConfirm = !_obscureConfirm
                  : _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Sign Up"),
      )
    );
  }
}
