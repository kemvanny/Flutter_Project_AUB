import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String title;
  String category;
  String priority;
  bool isDone;
  DateTime dueDate;
  String userId;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.isDone,
    required this.dueDate,
    required this.userId,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Task(
      id: doc.id,
      title: data['title'],
      category: data['category'],
      priority: data['priority'],
      isDone: data['isDone'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      userId: data['userId'],
    );
  }
}

