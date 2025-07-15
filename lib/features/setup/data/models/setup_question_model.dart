class SetupQuestionModel {
  final int id;
  final String question;
  final String description;
  final List<String> options;
  final String? selectedOption;

  SetupQuestionModel({
    required this.id,
    required this.question,
    required this.description,
    required this.options,
    this.selectedOption,
  });

  SetupQuestionModel copyWith({
    int? id,
    String? question,
    String? description,
    List<String>? options,
    String? selectedOption,
  }) {
    return SetupQuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      description: description ?? this.description,
      options: options ?? this.options,
      selectedOption: selectedOption ?? this.selectedOption,
    );
  }
} 