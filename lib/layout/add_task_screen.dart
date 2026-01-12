import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';
import '../widgets/ModernWowButton.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final TaskService _taskService = TaskService();

  // Predefined categories
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

  int _selectedIndex = 1; // Highlight Tasks tab

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // You can navigate to other main tabs/screens here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F6),
      appBar: AppBar(
        title: const Text(
          "Add New Task",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Modern Glass Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title
                  _modernInput(
                      controller: _titleController,
                      label: "Task Title",
                      icon: Icons.task_alt),
                  const SizedBox(height: 20),

                  // Category Selector - modern pill style
                  const Text(
                    "Category",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories
                          .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Select category",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Priority Selector
                  const Text(
                    "Priority",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: ["High", "Medium", "Low"].map((p) {
                      Color bg = p == "High"
                          ? Colors.redAccent
                          : p == "Medium"
                          ? Colors.orangeAccent
                          : Colors.green;
                      return ChoiceChip(
                        label: Text(p),
                        selected: _priority == p,
                        onSelected: (_) => setState(() => _priority = p),
                        selectedColor: bg,
                        backgroundColor: bg.withOpacity(0.2),
                        labelStyle: TextStyle(
                            color: _priority == p ? Colors.white : bg,
                            fontWeight: FontWeight.w600),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Deadline Picker
                  const Text(
                    "Deadline",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDateTime,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.purple.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDateTime != null
                                ? DateFormat('yyyy-MM-dd – HH:mm')
                                .format(_selectedDateTime!)
                                : "Select deadline",
                            style: TextStyle(
                              color: _selectedDateTime != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.purple),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Add Task Button with gradient and shadow
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: _addTask,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: Text(
                        "Add Task",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _modernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ---------------- PICK DATE/TIME ----------------
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
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // ---------------- ADD TASK ----------------
  Future<void> _addTask() async {
    if (_titleController.text.isEmpty || _selectedCategory == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final task = Task(
      id: '',
      title: _titleController.text,
      category: _selectedCategory!,
      priority: _priority,
      isDone: false,
      dueDate: _selectedDateTime ?? DateTime.now(),
      userId: uid,
    );

    await _taskService.addTask(task);
    Navigator.pop(context);
  }
}
