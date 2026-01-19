import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';
import '../widgets/ModernWowButton.dart';
import 'notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final TaskService _taskService = TaskService();

  final List<String> _categories = [
    "Daily Life",
    "Celebration",
    "Work",
    "School",
    "Other"
  ];

  String? _selectedCategory;
  String _priority = "Medium";
  DateTime? _selectedDateTime;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      appBar: AppBar(
        title: const Text(
          "Add New Task",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.purple.withOpacity(0.3),
        // soft shadow
        iconTheme: const IconThemeData(color: Colors.white),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF9F7AEA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _modernInput("Task Title", Icons.task_alt, _titleController),
            const SizedBox(height: 20),
            _modernDropdown(),
            const SizedBox(height: 20),
            _prioritySelector(),
            const SizedBox(height: 20),
            _deadlinePicker(),
            const SizedBox(height: 40),
            ModernWowButton(
              text: "Add Task",
              onPressed: _addTask,
              loading: _loading,
            ),
          ],
        ),
      ),
    );
  }

  // ================= MODERN INPUT =================
  Widget _modernInput(String label, IconData icon, TextEditingController c) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: c,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF7C3AED)),
          hintText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= MODERN DROPDOWN =================
  Widget _modernDropdown() {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategory,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          hintText: "Select Category",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        items: _categories
            .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c, style: const TextStyle(fontSize: 16)),
                ))
            .toList(),
        onChanged: (v) => setState(() => _selectedCategory = v),
      ),
    );
  }

  // ================= PRIORITY SELECTOR =================
  Widget _prioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Priority",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          children: ["High", "Medium", "Low"].map((p) {
            final selected = _priority == p;
            return ChoiceChip(
              label: Text(p,
                  style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold)),
              selected: selected,
              selectedColor: p == "High"
                  ? Colors.red
                  : p == "Medium"
                      ? const Color(0xFF7C3AED)
                      : Colors.green,
              backgroundColor: Colors.white,
              shadowColor: const Color(0xFF7C3AED).withOpacity(0.2),
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              onSelected: (_) => setState(() => _priority = p),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ================= DEADLINE PICKER =================
  Widget _deadlinePicker() {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Colors.white,
        leading: const Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
        title: Text(
          _selectedDateTime == null
              ? "Select Deadline"
              : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!),
          style: const TextStyle(fontSize: 16),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down),
        onTap: _pickDateTime,
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _addTask() async {
    if (_titleController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedDateTime == null) return;

    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final task = Task(
      id: '',
      title: _titleController.text.trim(),
      category: _selectedCategory!,
      priority: _priority,
      isDone: false,
      dueDate: _selectedDateTime!,
      userId: uid,
    );

    final taskId = await _taskService.addTask(task);

    final reminderTime =
        _selectedDateTime!.subtract(const Duration(minutes: 15));
    if (reminderTime.isAfter(DateTime.now())) {
      await NotificationService.scheduleTaskReminder(
        id: taskId.hashCode,
        title: task.title,
        dueDate: reminderTime,
      );
    }

    setState(() => _loading = false);
    Navigator.pop(context);
  }
}
