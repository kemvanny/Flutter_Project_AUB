import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');

  /// Get all tasks as a Stream of List<Task>
  Stream<List<Task>> getTasks() {
    return _tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};

        return Task(
          id: doc.id,
          title: data['title'] ?? '',
          category: data['category'] ?? '',
          isDone: data['isDone'] ?? false,
        );
      }).toList();
    });
  }

  /// Add a new task
  Future<void> addTask(Task task, String text) async {
    try {
      await _tasksCollection.add({
        'title': task.title,
        'category': task.category,
        'isDone': task.isDone,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      await _tasksCollection.doc(task.id).update({
        'title': task.title,
        'category': task.category,
        'isDone': task.isDone,
      });
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
