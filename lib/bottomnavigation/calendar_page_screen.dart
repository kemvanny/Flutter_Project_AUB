import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPageScreen extends StatefulWidget {
  const CalendarPageScreen({super.key});

  @override
  State<CalendarPageScreen> createState() => _CalendarPageScreenState();
}

class _CalendarPageScreenState extends State<CalendarPageScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Store events
  final Map<DateTime, List<String>> _events = {};

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _addEvent(String event) {
    final key =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

    if (_events[key] == null) {
      _events[key] = [];
    }
    _events[key]!.add(event);
    setState(() {});
  }

  void _showAddEventDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Event"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Event name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addEvent(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar Page"),
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 12),
          Icon(Icons.more_vert),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay)
                  .map(
                    (event) => ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(event),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: const Color(0xFFA5B4FC),
        child: const Icon(Icons.add),
      ),
    );
  }
}
