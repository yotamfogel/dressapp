
class UserModel {
  final int? id;
  final String email;
  final String? passwordHash;
  final String provider; // 'email', 'google', 'apple'
  final String? displayName;
  final String? photoUrl;

  UserModel({
    this.id,
    required this.email,
    this.passwordHash,
    required this.provider,
    this.displayName,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String?,
      provider: map['provider'] as String,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'passwordHash': passwordHash,
      'provider': provider,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  static String get createTableQuery => '''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE,
      passwordHash TEXT,
      provider TEXT,
      displayName TEXT,
      photoUrl TEXT
    )
  ''';
}

enum AuthProvider {
  email,
  google,
  apple,
} 