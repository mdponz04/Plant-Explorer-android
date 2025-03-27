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
      isCorrect: json['isCorrect'] ?? '',
    );
  }
}
