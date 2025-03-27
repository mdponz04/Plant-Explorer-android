class Question {
  final String name;
  final List<Option> options;
  final int point;
  final String context;

  Question({
    required this.name,
    required this.options,
    required this.point,
    required this.context,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      name: json['name'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((option) => Option.fromJson(option))
              .toList() ??
          [],
      point: json['point'] ?? 0,
      context: json['context'] ?? '',
    );
  }
}

class Option {
  final String context;
  final bool isCorrect;

  Option({
    required this.context,
    required this.isCorrect,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      context: json['context'] ?? '',
      isCorrect: json['isCorrect'] ?? false, // Ensure it's a boolean
    );
  }
}
