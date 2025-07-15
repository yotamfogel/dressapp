import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SetupDbHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'setup.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE setup_responses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question_id INTEGER,
            question_text TEXT,
            response TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> saveResponse(int questionId, String questionText, String response) async {
    final db = await database;
    await db.insert(
      'setup_responses',
      {
        'question_id': questionId,
        'question_text': questionText,
        'response': response,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<int, String>> getAllResponses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('setup_responses');
    
    Map<int, String> responses = {};
    for (var map in maps) {
      responses[map['question_id']] = map['response'];
    }
    return responses;
  }

  Future<void> clearAllResponses() async {
    final db = await database;
    await db.delete('setup_responses');
  }

  Future<bool> hasCompletedSetup() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM setup_responses');
    return result.first['count'] as int >= 5; // Assuming 5 questions
  }
} 