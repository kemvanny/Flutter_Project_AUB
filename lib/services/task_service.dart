import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';

class TaskService {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  // 🔥 STREAM TASKS (FILTERED BY USER)
  Stream<List<Task>> getTasks() {
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: _uid)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // ✅ ADD TASK
  Future<void> addTask(Task task) async {
    final doc = _db.collection('tasks').doc();

    await doc.set({
      'title': task.title,
      'category': task.category,
      'priority': task.priority,
      'isDone': task.isDone,
      'dueDate': task.dueDate,
      'userId': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ UPDATE
  Future<void> updateTask(Task task) async {
    await _db.collection('tasks').doc(task.id).update({
      'title': task.title,
      'category': task.category,
      'priority': task.priority,
      'isDone': task.isDone,
      'dueDate': Timestamp.fromDate(task.dueDate), // important
    });
  }

  // ✅ DELETE
  Future<void> deleteTask(String id) async {
    await _db.collection('tasks').doc(id).delete();
  }
}
