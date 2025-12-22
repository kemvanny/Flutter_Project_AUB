import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB7B2E8),
              Color(0xFFE8E7F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),

              /// Illustration
              SizedBox(
                height: size.height * 0.45,
                child: Image.asset(
                  "assets/images/img_logo.png",
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              /// Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(false),
                  _dot(false),
                  _dot(true),
                ],
              ),

              const SizedBox(height: 30),

              /// App Name
              Text(
                "PLANME",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade700,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 14),

              /// Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "PlanMe helps you create smart to-do lists, set reminders, and track your daily progress — all in one beautifully designed app.\n\nPlan smarter. Do better. Live balanced.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
              ),

              const Spacer(),

              /// Get Start Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to next screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB9B5F0),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Get start",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Indicator Dot
  Widget _dot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.indigo : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }
}
