import 'package:flutter/material.dart';

import 'calendar_page_screen.dart';
import 'mine_page_screen.dart';
import 'task_page_screen.dart';

class HomepageSceen extends StatefulWidget {
  const HomepageSceen({super.key});

  @override
  State<HomepageSceen> createState() => _HomepageSceenState();
}

class _HomepageSceenState extends State<HomepageSceen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    TaskPageScreen(),
    CalendarPageScreen(),
    MinePageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.task, "Task", 0),
            _navItem(Icons.calendar_month, "Calendar", 1),
            _navItem(Icons.person, "Mine", 2),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected ? Color(0xFF7C7AED) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isSelected ? Color(0xFF7C7AED) : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
