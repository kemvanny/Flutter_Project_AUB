import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ SAFELY GET UID (avoid null crash)
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ===================== GET TASKS =====================
  Stream<List<Task>> getTasks() {
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: _uid)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => Task.fromFirestore(doc))
          .toList(),
    );
  }

  // ===================== ADD TASK =====================
  // ✅ RETURN taskId (important for notifications)
  Future<String> addTask(Task task) async {
    final docRef = _db.collection('tasks').doc();

    await docRef.set({
      'title': task.title,
      'category': task.category,
      'priority': task.priority,
      'isDone': task.isDone,
      'dueDate': Timestamp.fromDate(task.dueDate), // ✅ correct
      'userId': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // ===================== UPDATE TASK =====================
  Future<void> updateTask(Task task) async {
    await _db.collection('tasks').doc(task.id).update({
      'title': task.title,
      'category': task.category,
      'priority': task.priority,
      'isDone': task.isDone,
      'dueDate': Timestamp.fromDate(task.dueDate), // ✅ important
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===================== DELETE TASK =====================
  Future<void> deleteTask(String id) async {
    await _db.collection('tasks').doc(id).delete();
  }
}
