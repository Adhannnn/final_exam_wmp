import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _dbName = 'app.db';
  static const int _dbVersion = 1;
  static Database? _database;

  // Open the database connection
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  // Create tables (user, subject, user_subject)
  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE subject (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        credits INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE user_subject (
        user_id INTEGER,
        subject_id INTEGER,
        PRIMARY KEY (user_id, subject_id),
        FOREIGN KEY (user_id) REFERENCES user(id),
        FOREIGN KEY (subject_id) REFERENCES subject(id)
      )
    ''');

    // Insert default subjects into the 'subject' table
    await _insertDefaultSubjects(db);
  }

  // Insert default subjects if they do not exist
  _insertDefaultSubjects(Database db) async {
    var result = await db.query('subject');
    if (result.isEmpty) {
      List<Map<String, dynamic>> defaultSubjects = [
        {'name': 'Wireless and Mobile Programming', 'credits': 3},
        {'name': 'Data Structure', 'credits': 4},
        {'name': 'Numerical Method', 'credits': 3},
        {'name': 'Artificial Intelligence', 'credits': 3},
        {'name': 'Network Security', 'credits': 3},
        {'name': 'Server Side', 'credits': 3},
        {'name': 'Object Oriented Virtual Programming', 'credits': 3},
        {'name': 'Web Programming', 'credits': 3},
        {'name': '3D Computer and Graphics Animation', 'credits': 4}
      ];

      for (var subject in defaultSubjects) {
        await db.insert('subject', subject);
      }
      print('Default subjects inserted.');
    }
  }

  // Register a new user
  Future<void> registerUser(String name, String email, String password) async {
    final db = await database;
    await db.insert('user', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  // Login user by checking email and password
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    var result = await db.query('user',
        where: 'email = ? AND password = ?', whereArgs: [email, password]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null; // Login failed
    }
  }

  // Get all subjects from the 'subject' table
  Future<List<Map<String, dynamic>>> getSubjects() async {
    final db = await database;
    return await db.query('subject');
  }

  // Enroll a user in a subject
  Future<void> enrollUserInSubject(int userId, int subjectId) async {
    final db = await database;
    await db.insert('user_subject', {
      'user_id': userId,
      'subject_id': subjectId,
    });
  }

  // Get the subjects a user is enrolled in
  Future<List<Map<String, dynamic>>> getUserSubjects(int userId) async {
    final db = await database;
    var result = await db.rawQuery('''
      SELECT s.id, s.name, s.credits 
      FROM subject s
      JOIN user_subject us ON s.id = us.subject_id
      WHERE us.user_id = ?
    ''', [userId]);
    return result;
  }

  // Get the total credits for a user
  Future<int> getTotalCredits(int userId) async {
    final db = await database;
    var result = await db.rawQuery('''
    SELECT SUM(s.credits) as totalCredits 
    FROM subject s
    JOIN user_subject us ON s.id = us.subject_id
    WHERE us.user_id = ?
  ''', [userId]);

    // Check if the result is not empty and return the total credits
    if (result.isNotEmpty && result.first['totalCredits'] != null) {
      return result.first['totalCredits'] as int;
    } else {
      return 0; // Return 0 if no result or the totalCredits is null
    }
  }
}
