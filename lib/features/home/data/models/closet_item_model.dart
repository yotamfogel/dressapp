import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_util;

class ColorInfo {
  final String name;
  final List<int> rgb;
  final double percentage;

  ColorInfo({
    required this.name,
    required this.rgb,
    required this.percentage,
  });

  factory ColorInfo.fromJson(Map<String, dynamic> json) {
    return ColorInfo(
      name: json['name'] ?? 'unknown',
      rgb: (json['rgb'] as List<dynamic>?)
              ?.map((value) => value as int)
              .toList() ??
          [0, 0, 0],
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rgb': rgb,
      'percentage': percentage,
    };
  }
}

class ClosetItemModel {
  final int? id;
  final String imagePath;
  final String? clothingType;
  final List<ColorInfo> colors;
  final List<String> patterns;
  final double confidence;
  final Map<String, dynamic> features;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClosetItemModel({
    this.id,
    required this.imagePath,
    this.clothingType,
    this.colors = const [],
    this.patterns = const [],
    this.confidence = 0.0,
    this.features = const {},
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'clothingType': clothingType,
      'colors': colors.map((color) => color.toMap()).toList(),
      'patterns': patterns,
      'confidence': confidence,
      'features': features,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory ClosetItemModel.fromMap(Map<String, dynamic> map) {
    return ClosetItemModel(
      id: map['id'] as int?,
      imagePath: map['imagePath'] as String,
      clothingType: map['clothingType'] as String?,
      colors: (map['colors'] as List<dynamic>?)
              ?.map((color) => ColorInfo.fromJson(color))
              .toList() ??
          [],
      patterns: (map['patterns'] as List<dynamic>?)
              ?.map((pattern) => pattern as String)
              .toList() ??
          [],
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      features: (map['features'] as Map<String, dynamic>?) ?? {},
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
    );
  }

  ClosetItemModel copyWith({
    int? id,
    String? imagePath,
    String? clothingType,
    List<ColorInfo>? colors,
    List<String>? patterns,
    double? confidence,
    Map<String, dynamic>? features,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClosetItemModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      clothingType: clothingType ?? this.clothingType,
      colors: colors ?? this.colors,
      patterns: patterns ?? this.patterns,
      confidence: confidence ?? this.confidence,
      features: features ?? this.features,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ClosetDatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbPathJoined = path_util.join(dbPath, 'closet.db');

    return await openDatabase(
      dbPathJoined,
      version: 2, // Updated version for new schema
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE closet_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT NOT NULL,
            clothingType TEXT,
            colors TEXT,
            patterns TEXT,
            confidence REAL DEFAULT 0.0,
            features TEXT,
            createdAt INTEGER,
            updatedAt INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add new columns for AI detection data
          await db.execute('ALTER TABLE closet_items ADD COLUMN clothingType TEXT');
          await db.execute('ALTER TABLE closet_items ADD COLUMN colors TEXT');
          await db.execute('ALTER TABLE closet_items ADD COLUMN patterns TEXT');
          await db.execute('ALTER TABLE closet_items ADD COLUMN confidence REAL DEFAULT 0.0');
          await db.execute('ALTER TABLE closet_items ADD COLUMN features TEXT');
          await db.execute('ALTER TABLE closet_items ADD COLUMN createdAt INTEGER');
          await db.execute('ALTER TABLE closet_items ADD COLUMN updatedAt INTEGER');
        }
      },
    );
  }

  static Future<int> insertItem(ClosetItemModel item) async {
    final db = await database;
    return await db.insert('closet_items', {
      'imagePath': item.imagePath,
      'clothingType': item.clothingType,
      'colors': jsonEncode(item.colors.map((c) => c.toMap()).toList()),
      'patterns': jsonEncode(item.patterns),
      'confidence': item.confidence,
      'features': jsonEncode(item.features),
      'createdAt': item.createdAt?.millisecondsSinceEpoch,
      'updatedAt': item.updatedAt?.millisecondsSinceEpoch,
    });
  }

  static Future<List<ClosetItemModel>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('closet_items');
    
    return List.generate(maps.length, (i) {
      final map = maps[i];
      return ClosetItemModel(
        id: map['id'] as int?,
        imagePath: map['imagePath'] as String,
        clothingType: map['clothingType'] as String?,
        colors: _parseColors(map['colors'] as String?),
        patterns: _parsePatterns(map['patterns'] as String?),
        confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
        features: _parseFeatures(map['features'] as String?),
        createdAt: map['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
            : null,
        updatedAt: map['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
            : null,
      );
    });
  }

  static Future<int> updateItem(ClosetItemModel item) async {
    final db = await database;
    return await db.update(
      'closet_items',
      {
        'imagePath': item.imagePath,
        'clothingType': item.clothingType,
        'colors': jsonEncode(item.colors.map((c) => c.toMap()).toList()),
        'patterns': jsonEncode(item.patterns),
        'confidence': item.confidence,
        'features': jsonEncode(item.features),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  static Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'closet_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static List<ColorInfo> _parseColors(String? colorsJson) {
    if (colorsJson == null) return [];
    try {
      final List<dynamic> colorsList = jsonDecode(colorsJson);
      return colorsList.map((color) => ColorInfo.fromJson(color)).toList();
    } catch (e) {
      return [];
    }
  }

  static List<String> _parsePatterns(String? patternsJson) {
    if (patternsJson == null) return [];
    try {
      final List<dynamic> patternsList = jsonDecode(patternsJson);
      return patternsList.map((pattern) => pattern.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  static Map<String, dynamic> _parseFeatures(String? featuresJson) {
    if (featuresJson == null) return {};
    try {
      final Map<String, dynamic> features = jsonDecode(featuresJson);
      return features;
    } catch (e) {
      return {};
    }
  }
} 