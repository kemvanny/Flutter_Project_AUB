import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TaskService _taskService = TaskService();
  List<Task> _tasksForSelectedDay = [];
  String _filter = "All"; // Filter: All, Completed, Pending

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _calendarCard(),
            const SizedBox(height: 16),
            _taskListCard(),
          ],
        ),
      ),
    );
  }

  /// Calendar card with event markers
  Widget _calendarCard() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 6,
          shadowColor: Colors.purple.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _tasksForSelectedDay = tasks
                      .where((t) =>
                          t.dueDate.year == selectedDay.year &&
                          t.dueDate.month == selectedDay.month &&
                          t.dueDate.day == selectedDay.day)
                      .toList();
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.purpleAccent],
                  ),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrangeAccent],
                  ),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              eventLoader: (day) {
                return tasks
                    .where((t) =>
                        t.dueDate.year == day.year &&
                        t.dueDate.month == day.month &&
                        t.dueDate.day == day.day)
                    .toList();
              },
            ),
          ),
        );
      },
    );
  }

  /// Task list card with summary and swipe actions
  Widget _taskListCard() {
    final filteredTasks = _tasksForSelectedDay.where((t) {
      if (_filter == "All") return true;
      if (_filter == "Completed") return t.isDone;
      if (_filter == "Pending") return !t.isDone;
      return true;
    }).toList();

    final completedCount = _tasksForSelectedDay.where((t) => t.isDone).length;
    final pendingCount = _tasksForSelectedDay.length - completedCount;

    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        shadowColor: Colors.purple.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task summary + filter buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tasks: ${_tasksForSelectedDay.length}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: ["All", "Pending", "Completed"].map((f) {
                      return ChoiceChip(
                        label: Text(
                          f,
                          style: TextStyle(
                            fontSize: 11,
                            color: _filter == f ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                        selectedColor: Colors.purpleAccent,
                        backgroundColor: Colors.grey[200],
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Task list
              filteredTasks.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Text(
                          _selectedDay != null
                              ? "No tasks for ${DateFormat.MMMd().format(_selectedDay!)}"
                              : "Select a day to view tasks",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return Dismissible(
                            key: Key(task.id),
                            background: Container(
                              color: Colors.green,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child:
                                  const Icon(Icons.check, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              if (direction == DismissDirection.startToEnd) {
                                setState(() {
                                  task.isDone = true;
                                  _taskService.updateTask(task);
                                });
                              } else {
                                _taskService.deleteTask(task.id);
                                setState(() {
                                  _tasksForSelectedDay.remove(task);
                                });
                              }
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: task.isDone
                                    ? Colors.green
                                    : task.priority == "High"
                                        ? Colors.red
                                        : task.priority == "Medium"
                                            ? Colors.orange
                                            : Colors.blue,
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: task.isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              subtitle: Text(
                                "Due: ${DateFormat.MMMd().format(task.dueDate)}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              onTap: () => _showEditTaskDialog(task),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    String priority = "Low"; // <-- make sure this exists
    DateTime dueDate = _selectedDay ?? DateTime.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Task title"),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: priority,
              items: ["Low", "Medium", "High"]
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => priority = v!,
              decoration: const InputDecoration(labelText: "Priority"),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: dueDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) dueDate = picked;
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "Due Date"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat.MMMd().format(dueDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }

  /// Edit Task Dialog
  void _showEditTaskDialog(Task task) {
    final titleController = TextEditingController(text: task.title);
    String priority = task.priority;
    DateTime dueDate = task.dueDate;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Task title"),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: priority,
              items: ["Low", "Medium", "High"]
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => priority = v!,
              decoration: const InputDecoration(labelText: "Priority"),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: dueDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) dueDate = picked;
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "Due Date"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat.MMMd().format(dueDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                task.title = titleController.text.trim();
                task.priority = priority;
                task.dueDate = dueDate;
                _taskService.updateTask(task);
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
