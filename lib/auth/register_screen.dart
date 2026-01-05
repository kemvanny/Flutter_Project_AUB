import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

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
    super.dispose();
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

  // Animated Background
  Widget _animatedBackground() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
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
              _circle(
                120,
                80 + 40 * sin(_controller.value * 2 * pi),
                230,
                Colors.white.withOpacity(0.08),
              ),
              _circle(
                420 + 50 * cos(_controller.value * 2 * pi),
                260,
                300,
                Colors.white.withOpacity(0.06),
              ),
              _circle(
                220,
                -140 + 60 * sin(_controller.value * 2 * pi),
                190,
                Colors.white.withOpacity(0.07),
              ),
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
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  // 🧾 Content
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
                child: Transform.translate(
                  offset: Offset(0, 40 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _registerCard(),
          ),
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
            color: Colors.white.withOpacity(0.25), // glass
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
              const SizedBox(height: 10),
              Text(
                "Create your account",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              _input("Full Name", Icons.person_outline),
              const SizedBox(height: 18),
              _input("Email", Icons.email_outlined),
              const SizedBox(height: 18),
              _input(
                "Password",
                Icons.lock_outline,
                isPassword: true,
                isConfirm: false,
              ),
              const SizedBox(height: 18),
              _input(
                "Confirm Password",
                Icons.lock_reset_outlined,
                isPassword: true,
                isConfirm: true,
              ),
              const SizedBox(height: 32),

              _registerButton(),
            ],
          ),
        ),
      ),
    );
  }


  // Modern Input
  Widget _input(
      String hint,
      IconData icon, {
        bool isPassword = false,
        bool isConfirm = false,
      }) {
    return TextField(
      obscureText: isPassword
          ? (isConfirm ? _obscureConfirm : _obscurePassword)
          : false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isConfirm
                ? (_obscureConfirm
                ? Icons.visibility_off
                : Icons.visibility)
                : (_obscurePassword
                ? Icons.visibility_off
                : Icons.visibility),
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              if (isConfirm) {
                _obscureConfirm = !_obscureConfirm;
              } else {
                _obscurePassword = !_obscurePassword;
              }
            });
          },
        )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFF6366F1),
            width: 1.8,
          ),
        ),
      ),
    );
  }

  //Register Button
  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
