import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'task_model.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            isDone INTEGER
          )
        ''');
      },
    );
  }

  static Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(
      'tasks',
      orderBy: 'id DESC',
    );
    return data.map((e) => Task.fromMap(e)).toList();
  }

  static Future<Task> insertTask(Task task) async {
    final db = await database;
    final id = await db.insert('tasks', task.toMap());
    task.id = id;
    return task;
  }

  static Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // ✅ Add this method for deleting tasks
  static Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
