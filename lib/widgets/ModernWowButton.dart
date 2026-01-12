import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModernWowButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool loading;

  const ModernWowButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  State<ModernWowButton> createState() => _ModernWowButtonState();
}

class _ModernWowButtonState extends State<ModernWowButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.loading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 60,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF9D4EDD), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: _pressed
              ? [
            BoxShadow(
              color: Colors.purple.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 1,
            )
          ]
              : [
            BoxShadow(
              color: Colors.purple.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.15),
              blurRadius: 25,
              spreadRadius: 2,
            )
          ],
        ),
        transform: Matrix4.identity()..scale(_pressed ? 0.95 : 1.0),
        child: widget.loading
            ? const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        )
            : Stack(
          alignment: Alignment.center,
          children: [
            // Glow animation effect
            Positioned(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.25),
                      Colors.transparent
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Text(
              widget.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
