import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'user_model.dart';
import 'dart:async';

class AuthDbHelper {
  static final AuthDbHelper _instance = AuthDbHelper._internal();
  factory AuthDbHelper() => _instance;
  AuthDbHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auth.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(UserModel.createTableQuery);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add missing columns for version 2
          await db.execute('ALTER TABLE users ADD COLUMN provider TEXT DEFAULT "email"');
          await db.execute('ALTER TABLE users ADD COLUMN displayName TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN photoUrl TEXT');
        }
      },
    );
  }

  Future<int> upsertUser(UserModel user) async {
    final db = await database;
    final existing = await getUserByEmail(user.email);
    if (existing == null) {
      return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
    } else {
      // Only update allowed fields, not id or passwordHash
      return await db.update(
        'users',
        {
          'email': user.email,
          'provider': user.provider,
          'displayName': user.displayName,
          'photoUrl': user.photoUrl,
        },
        where: 'email = ?',
        whereArgs: [user.email],
      );
    }
  }

  Future<UserModel?> getUserByEmailAndProvider(String email, String provider) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ? AND provider = ?', whereArgs: [email, provider]);
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> registerUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<UserModel?> loginUser(String email, String passwordHash) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ? AND passwordHash = ?', whereArgs: [email, passwordHash]);
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.close();
    _db = null;
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auth.db');
    
    // Delete the database file
    await deleteDatabase(path);
    
    // Reinitialize the database
    await database;
  }
} 