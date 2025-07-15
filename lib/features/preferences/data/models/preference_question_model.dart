class PreferenceQuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final String? userAnswer;
  final DateTime? answeredAt;

  const PreferenceQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    this.userAnswer,
    this.answeredAt,
  });

  PreferenceQuestionModel copyWith({
    String? id,
    String? question,
    List<String>? options,
    String? userAnswer,
    DateTime? answeredAt,
  }) {
    return PreferenceQuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      userAnswer: userAnswer ?? this.userAnswer,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'userAnswer': userAnswer,
      'answeredAt': answeredAt?.toIso8601String(),
    };
  }

  factory PreferenceQuestionModel.fromJson(Map<String, dynamic> json) {
    return PreferenceQuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      userAnswer: json['userAnswer'] as String?,
      answeredAt: json['answeredAt'] != null 
          ? DateTime.parse(json['answeredAt'] as String)
          : null,
    );
  }
} 