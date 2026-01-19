import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();

  // Filters
  String? _selectedMonth;
  String? _selectedCategory;
  String? _selectedPriority;

  final List<String> _months = List.generate(
      12, (index) => DateFormat.MMMM().format(DateTime(0, index + 1)));
  final List<String> _categories = [
    "Daily Life",
    "Celebration",
    "Work",
    "School",
    "Other"
  ];
  final List<String> _priorities = ["High", "Medium", "Low"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilters(),
        const SizedBox(height: 8),
        _buildTaskCount(),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<List<Task>>(
            stream: _taskService.getTasks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<Task> tasks = snapshot.data ?? [];

              // Apply filters
              if (_selectedMonth != null && _selectedMonth != "All") {
                final monthIndex = _months.indexOf(_selectedMonth!) + 1;
                tasks =
                    tasks.where((t) => t.dueDate.month == monthIndex).toList();
              }

              if (_selectedCategory != null && _selectedCategory != "All") {
                tasks = tasks
                    .where((t) => t.category == _selectedCategory)
                    .toList();
              }

              if (_selectedPriority != null && _selectedPriority != "All") {
                tasks = tasks
                    .where((t) => t.priority == _selectedPriority)
                    .toList();
              }

              if (tasks.isEmpty) return _emptyState("No tasks found");

              return GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 3 / 2.2,
                ),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskCard(task);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    final isOverdue = !task.isDone && task.dueDate.isBefore(DateTime.now());

    // Priority color
    Color priorityColor;
    switch (task.priority) {
      case "High":
        priorityColor = Colors.red;
        break;
      case "Medium":
        priorityColor = Colors.purple;
        break;
      case "Low":
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _taskService.deleteTask(task.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: task.isDone
              ? LinearGradient(colors: [Colors.green[100]!, Colors.green[50]!])
              : isOverdue
                  ? LinearGradient(colors: [Colors.red[100]!, Colors.red[50]!])
                  : LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.priority,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isOverdue ? Colors.red : Colors.black87,
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.MMMd().format(task.dueDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.red[700] : Colors.grey[700],
                        ),
                      ),
                      Text(
                        task.category,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Checkbox(
                    visualDensity: VisualDensity.compact, // ⭐ IMPORTANT
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: task.isDone,
                    activeColor: Colors.purple,
                    onChanged: (v) {
                      setState(() {
                        task.isDone = v!;
                        _taskService.updateTask(task);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Filters row
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildFilterButton(
            label: "Month",
            value: _selectedMonth,
            items: ["All", ..._months],
            onSelected: (v) => setState(() => _selectedMonth = v),
          ),
          _buildFilterButton(
            label: "Category",
            value: _selectedCategory,
            items: ["All", ..._categories],
            onSelected: (v) => setState(() => _selectedCategory = v),
          ),
          _buildFilterButton(
            label: "Priority",
            value: _selectedPriority,
            items: ["All", ..._priorities],
            onSelected: (v) => setState(() => _selectedPriority = v),
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedMonth = null;
                _selectedCategory = null;
                _selectedPriority = null;
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.purple),
            label: const Text("Reset", style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) =>
          items.map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple),
        ),
        child: Text(
          value ?? label,
          style: TextStyle(
            color: value == null
                ? Colors.purple[700]
                : const Color.fromARGB(255, 168, 80, 184),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCount() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "$count Tasks",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
