import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? 'testUser';
  final Uuid _uuid = Uuid();
  late final taskId = _uuid.v4();

  CollectionReference get _taskCollection =>
      _firestore.collection('users').doc(_userId).collection('tasks');

  Stream<List<Task>> getTasks() {
    return _taskCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> addTask(String title, String category) async {
    final taskId = _uuid.v4();
    await _taskCollection.doc(taskId).set(Task(id: taskId, title: title, category: category).toMap());
  }

  Future<void> updateTask(Task task) async {
    await _taskCollection.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _taskCollection.doc(id).delete();
  }
}
