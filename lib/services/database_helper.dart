import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/task.dart';

/// A singleton class that provides access to the SQLite database for managing tasks.
///
/// This class handles database initialization, task insertion, retrieval, and updates.
/// It uses the sqflite package to perform database operations.
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  // Factory constructor to return the same instance
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  /// Gets the database instance, initializing it if necessary.
  ///
  /// Returns a [Database] instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database and creates the tasks table.
  ///
  /// Returns a [Database] instance after creating the necessary tables.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, location TEXT, status TEXT)',
        );
      },
    );
  }

  /// Inserts a new task into the database.
  ///
  /// Takes a [Task] object and saves it to the tasks table.
  /// If a task with the same ID exists, it will be replaced.
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all tasks from the database.
  ///
  /// Returns a list of [Task] objects representing all tasks in the database.
  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        location: maps[i]['location'],
        status: maps[i]['status'],
      );
    });
  }

  /// Updates the status of a specific task in the database.
  ///
  /// Takes the [taskId] of the task to update and the new status as a string.
  Future<void> updateTask(int taskId, String newStatus) async {
    final db = await database;
    await db.update(
      'tasks',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }
}