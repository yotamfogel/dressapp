import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/auth/data/models/auth_db_helper.dart';
import '../../features/setup/data/models/setup_db_helper.dart';

class DatabaseCleanupService {
  static final DatabaseCleanupService _instance = DatabaseCleanupService._internal();
  factory DatabaseCleanupService() => _instance;
  DatabaseCleanupService._internal();

  Future<void> clearAllDatabases() async {
    try {
      // Clear auth database
      final authHelper = AuthDbHelper();
      await authHelper.clearAllData();
      
      // Clear setup database
      final setupHelper = SetupDbHelper();
      await setupHelper.clearAllResponses();
      
      print('All databases cleared successfully');
    } catch (e) {
      print('Error clearing databases: $e');
    }
  }

  Future<void> resetAllDatabases() async {
    try {
      // Reset auth database
      final authHelper = AuthDbHelper();
      await authHelper.resetDatabase();
      
      // Reset setup database by deleting the file
      final dbPath = await getDatabasesPath();
      final setupDbPath = join(dbPath, 'setup.db');
      await deleteDatabase(setupDbPath);
      
      print('All databases reset successfully');
    } catch (e) {
      print('Error resetting databases: $e');
    }
  }
} 