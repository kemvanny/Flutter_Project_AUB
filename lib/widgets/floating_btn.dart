import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatingButton extends StatefulWidget {
  final VoidCallback onTap;

  const FloatingButton({super.key, required this.onTap});

  @override
  State<FloatingButton> createState() => _WowFloatingButtonState();
}

class _WowFloatingButtonState extends State<FloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 68,
          width: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9D4EDD),
                Color(0xFF7C3AED),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.55),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.25),
                blurRadius: 40,
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 34,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
