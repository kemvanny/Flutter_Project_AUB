import 'package:flutter/material.dart';

class MinePageScreen extends StatefulWidget {
  const MinePageScreen({super.key});

  @override
  State<MinePageScreen> createState() => _MinePageScreenState();
}

class _MinePageScreenState extends State<MinePageScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Mini Page",
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}
