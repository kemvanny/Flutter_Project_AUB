import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // For swipe actions

import 'dbhelper.dart';
import 'task_model.dart';

class TaskPageScreen extends StatefulWidget {
  const TaskPageScreen({super.key});

  @override
  State<TaskPageScreen> createState() => _TaskPageScreenState();
}

class _TaskPageScreenState extends State<TaskPageScreen> {
  List<Task> tasks = []; // List to hold all tasks
  final TextEditingController _taskController =
      TextEditingController(); // Controller for bottom sheet input

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks from DB when page opens
  }

  // Load tasks from the database
  Future<void> _loadTasks() async {
    final data = await DBHelper.getTasks();
    if (!mounted) return;
    setState(() => tasks = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks Page')),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
              'No Tasks yet',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            )) // Show message if no tasks
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return _taskItem(tasks[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context), // Open add task sheet
        backgroundColor: const Color(0xFFA5B4FC),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Single task item with swipe actions on the right
  Widget _taskItem(Task task) {
    return Slidable(
      key: ValueKey(task.id),
      // RIGHT swipe actions
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          // Update button
          SlidableAction(
            onPressed: (context) => _showUpdateTaskSheet(task),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Update',
          ),
          // Delete button
          SlidableAction(
            onPressed: (context) async {
              await _deleteTask(task);
              Slidable.of(context)?.close(); // Close swipe after delete
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Circle checkbox for task done
            SizedBox(
              width: 40,
              height: 30,
              child: GestureDetector(
                onTap: () async {
                  setState(() => task.isDone = !task.isDone); // Toggle done
                  await DBHelper.updateTask(task); // Update DB
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isDone ? Colors.blue : Colors.white,
                        border: task.isDone
                            ? null
                            : Border.all(color: Colors.grey, width: 2),
                      ),
                      child: task.isDone
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Task title
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  color: task.isDone ? Colors.grey : Colors.black,
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show bottom sheet to add a new task
  void _showAddTaskSheet(BuildContext parentContext) {
    _taskController.clear(); // Clear previous input
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  hintText: 'Input new task here',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB7B2E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                ),
                child: const Text(
                  'Add Task',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                onPressed: () async {
                  if (_taskController.text.trim().isEmpty) return;

                  final task = Task(title: _taskController.text.trim());
                  final savedTask = await DBHelper.insertTask(task);
                  if (!mounted) return;

                  setState(() {
                    tasks.insert(0, savedTask); // Add to list UI
                  });

                  _taskController.clear();
                  Navigator.pop(parentContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Delete task
  Future<void> _deleteTask(Task task) async {
    if (task.id == null) return;

    try {
      await DBHelper.deleteTask(task.id!); // Delete from DB
      setState(() {
        tasks.removeWhere((t) => t.id == task.id); // Remove from UI
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting task')),
      );
    }
  }

  // Show bottom sheet to update task
  void _showUpdateTaskSheet(Task task) {
    _taskController.text = task.title; // Set current title
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  hintText: 'Update task',
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB7B2E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                ),
                child: const Text(
                  'Update Task',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                onPressed: () async {
                  if (_taskController.text.trim().isEmpty) return;

                  task.title = _taskController.text.trim();
                  await DBHelper.updateTask(task); // Update in DB
                  await _loadTasks(); // Reload list

                  _taskController.clear();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
