import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_aub/layout/calendar_screen.dart';
import 'package:flutter_project_aub/layout/setting_screen.dart';
import 'package:flutter_project_aub/layout/tasks_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';
import '../widgets/floating_btn.dart';
import 'add_task_screen.dart';

enum TaskFilter { all, completed, pending }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  int _currentIndex = 0;
  TaskFilter _filter = TaskFilter.all;
  String? selectedTaskId;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex <= 1
          ? FloatingButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                );
              },
            )
          : null,
      extendBody: true, // makes bottom nav float above content
    );
  }

  // App Bar
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(88),
      child: Container(
        height: 200,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF9F7AEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Menu icon with circle background
                Builder(
                  builder: (context) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.menu, color: Colors.white, size: 25),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                // Title / Profile
                Expanded(
                  child: _currentIndex == 0
                      ? _buildProfileHeader() // your profile widget
                      : Center(
                          child: Text(
                            _currentIndex == 1
                                ? "Tasks"
                                : _currentIndex == 2
                                    ? "Calendar"
                                    : "Settings",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),

                // Notification icon with circle background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 25,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        backgroundColor: Colors.white,
                        builder: (context) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Column(
                              children: [
                                // Drag handle
                                Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(top: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Title
                                const Text(
                                  "Notifications",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 24),
                                // Centered message
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "No Notifications Yet",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= PROFILE HEADER =================
  Widget _buildProfileHeader() {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.purple[300]!,
                highlightColor: Colors.purple[100]!,
                child: const CircleAvatar(radius: 20),
              ),
              const SizedBox(width: 12),
              Container(width: 100, height: 14, color: Colors.white),
            ],
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final name = data['fullName'] ?? 'User';
        final image = data['profileUrl'] ?? '';
        final gender = data['gender']; // male/female/null

        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage: image.isNotEmpty
                  ? NetworkImage(image)
                  : (gender == 'male'
                      ? const AssetImage('assets/images/default_profile.png')
                      : gender == 'female'
                          ? const AssetImage(
                              'assets/images/default_pf_girl.png')
                          : null) as ImageProvider?,
              child: image.isEmpty && gender == null
                  ? const Icon(Icons.person, size: 20, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ================= BODY =================
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const TasksScreen();
      case 2:
        return const CalendarScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const SizedBox();
    }
  }

  // ================= HOME TAB =================
  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _searchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskService.getTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final tasks = snapshot.data ?? [];
                //search and filter
                final filteredTasks = _applySearch(_applyFilter(tasks));

                final total = tasks.length;
                final completed = tasks.where((t) => t.isDone).length;
                final pending = total - completed;

                //search empty state
                if (filteredTasks.isEmpty) {
                  return _emptyState("No matching tasks found");
                }

                return Column(
                  children: [
                    _buildStats(total, completed, pending),
                    const SizedBox(height: 12),
                    _buildFilterTabs(),
                    const SizedBox(height: 12),
                    _carditem(filteredTasks),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateTaskBottomSheet(Task task) {
    final titleController = TextEditingController(text: task.title);
    String priority = task.priority; // Add priority edit if needed
    DateTime dueDate = task.dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
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
              // Drag handle
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                "Update Task",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Task Title Input
              TextField(
                controller: titleController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: "Task Title",
                  prefixIcon:
                      const Icon(Icons.task_alt, color: Color(0xFF7C3AED)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Priority Dropdown
              DropdownButtonFormField<String>(
                initialValue: priority,
                items: ["Low", "Medium", "High"]
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              Icon(
                                p == "Low"
                                    ? Icons.arrow_downward
                                    : p == "Medium"
                                        ? Icons.trending_flat
                                        : Icons.arrow_upward,
                                color: p == "Low"
                                    ? Colors.green
                                    : p == "Medium"
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(p),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => priority = v!,
                decoration: InputDecoration(
                  labelText: "Priority",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Due Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => dueDate = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Due Date",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today,
                        color: Color(0xFF7C3AED)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.yMMMEd().format(dueDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;

                    task.title = titleController.text.trim();
                    task.priority = priority;
                    task.dueDate = dueDate;

                    await _taskService.updateTask(task);

                    // Schedule notification for updated task
                    // await _scheduleTaskNotification(task);

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Update Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _carditem(List<Task> filteredTasks) {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];

          return Slidable(
            key: ValueKey(task.id),

            //  SWIPE LEFT
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
                // UPDATE
                SlidableAction(
                  onPressed: (context) {
                    _showUpdateTaskBottomSheet(task);
                  },
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Update',
                ),

                // DELETE
                SlidableAction(
                  onPressed: (context) async {
                    await _taskService.deleteTask(task.id);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),

            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        task.isDone = !task.isDone; // toggle
                      });
                      await _taskService.updateTask(task);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isDone ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                        color: task.isDone ? Colors.green : Colors.transparent,
                      ),
                      child: task.isDone
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                task.isDone ? Colors.red[500] : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Due: ${DateFormat.MMMd().format(task.dueDate)}",
                          style: TextStyle(
                            color:
                                task.isDone ? Colors.red[500] : Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= FILTER =================
  List<Task> _applyFilter(List<Task> tasks) {
    switch (_filter) {
      case TaskFilter.completed:
        return tasks.where((t) => t.isDone).toList();
      case TaskFilter.pending:
        return tasks.where((t) => !t.isDone).toList();
      case TaskFilter.all:
      default:
        return tasks;
    }
  }

  Widget _buildFilterTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _filterButton("All", TaskFilter.all),
        _filterButton("Completed", TaskFilter.completed),
        _filterButton("Pending", TaskFilter.pending),
      ],
    );
  }

  Widget _filterButton(String title, TaskFilter filter) {
    final isSelected = _filter == filter;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? const Color(0xFF7C3AED) : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        onPressed: () {
          setState(() => _filter = filter);
        },
        child: Text(title),
      ),
    );
  }

  // ================= STATS =================
  Widget _buildStats(int total, int completed, int pending) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statCard("Total", total, Colors.purple),
        _statCard("Completed", completed, Colors.green),
        _statCard("Pending", pending, Colors.orange),
      ],
    );
  }

  Widget _statCard(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value.toString(),
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  // ================= TASKS TAB =================
  Widget _buildTasksTab() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data ?? [];
        if (tasks.isEmpty) return _emptyState("No tasks yet");

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3 / 2,
          ),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: task.isDone ? Colors.green[50] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration:
                              task.isDone ? TextDecoration.lineThrough : null)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat.MMMd().format(task.dueDate),
                          style: const TextStyle(fontSize: 12)),
                      Checkbox(
                        value: task.isDone,
                        onChanged: (v) {
                          task.isDone = v!;
                          _taskService.updateTask(task);
                        },
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================= CALENDAR TAB =================
  Widget _buildCalendarTab() {
    return const Center(child: Text("Calendar View"));
  }

  // ================= DRAWER =================
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ===== DRAWER HEADER =====
          _buildDrawerHeader(),
          const SizedBox(height: 20),
          // ===== MENU ITEMS =====
          _drawerItem(Icons.home_rounded, "Home", 0),
          _drawerItem(Icons.check_circle_rounded, "Tasks", 1),
          _drawerItem(Icons.calendar_month_rounded, "Calendar", 2),
          _drawerItem(Icons.settings_rounded, "Settings", 3),
          const Spacer(),
          // ===== LOGOUT =====
          _drawerLogout(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

// ================= DRAWER HEADER =================
  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      height: 250, // taller height
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF9F7AEA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 40, backgroundColor: Colors.white),
                const SizedBox(height: 16),
                Container(width: 120, height: 20, color: Colors.white),
                const SizedBox(height: 6),
                Container(width: 80, height: 16, color: Colors.white),
              ],
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['fullName'] ?? 'User';
          final image = data['profileUrl'] ?? '';
          final gender = data['gender'];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: image.isNotEmpty
                    ? NetworkImage(image)
                    : (gender == 'male'
                        ? const AssetImage('assets/images/default_profile.png')
                        : gender == 'female'
                            ? const AssetImage(
                                'assets/images/default_pf_girl.png')
                            : null) as ImageProvider?,
                child: image.isEmpty && gender == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "View Profile",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

// ================= DRAWER ITEMS =================
  Widget _drawerItem(IconData icon, String title, int index) {
    final bool active = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.of(context).pop(); // close drawer
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.purple.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: active ? const Color(0xFF7C3AED) : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: active ? const Color(0xFF7C3AED) : Colors.grey[800],
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerLogout() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.logout,
                    size: 50,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Are you sure you want to logout?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      //Cancel
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop(); // close dialog
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Logout
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            Navigator.of(ctx).pop(); // close dialog

                            await FirebaseAuth.instance.signOut();

                            // If you DO NOT use AuthGate, uncomment below:

                            if (!context.mounted) return;
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/welcome',
                              (route) => false,
                            );
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },

      // ===== Drawer Logout Button UI =====
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              "Logout",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM NAV =================
  Widget _buildBottomNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(Icons.home_rounded, "Home", 0),
              _navItem(Icons.check_circle_rounded, "Tasks", 1),
              _navItem(Icons.calendar_month_rounded, "Calendar", 2),
              _navItem(Icons.settings_rounded, "Settings", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool active = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding:
            EdgeInsets.symmetric(horizontal: active ? 20 : 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                )
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: active ? Colors.white : Colors.grey,
              size: 24,
            ),
            if (active) ...[
              const SizedBox(width: 8),
              AnimatedOpacity(
                opacity: active ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================
  Widget _emptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt,
              size: 120, color: Colors.purple.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(text,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          const Text("Tap + to add your first task",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ================= SEARCH BAR =================
  // ================= SEARCH BAR =================
  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.purple.withOpacity(0.15), blurRadius: 10)
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchText = value.toLowerCase();
          });
        },
        decoration: const InputDecoration(
          hintText: "Search tasks...",
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }

  List<Task> _applySearch(List<Task> tasks) {
    if (_searchText.isEmpty) return tasks;

    return tasks.where((task) {
      return task.title.toLowerCase().contains(_searchText) ||
          task.category.toLowerCase().contains(_searchText) ||
          task.priority.toLowerCase().contains(_searchText);
    }).toList();
  }

  // ================= NOTIFICATION HELPERS =================
  // Future<void> _scheduleTaskNotification(Task task) async {
  //   try {
  //     await NotificationService.scheduleTaskReminder(
  //       id: task.id.hashCode, // unique ID per task
  //       title: task.title,
  //       dueDate: task.dueDate,
  //     );
  //     print("Notification scheduled for ${task.dueDate}");
  //   } catch (e) {
  //     print("Error scheduling notification: $e");
  //   }
  // }

  // Future<void> _cancelTaskNotification(Task task) async {
  //   try {
  //     await NotificationService.cancel(task.id.hashCode);
  //   } catch (e) {
  //     print("Error cancelling notification: $e");
  //   }
  // }
}
