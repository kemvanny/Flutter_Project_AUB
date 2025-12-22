class Task {
  String id;
  String title;
  String category;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.category,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'isDone': isDone,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }
}
