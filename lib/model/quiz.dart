class Quiz {
  final String id;
  final String name;
  final String imageUrl;

  Quiz({
    required this.id,
    required this.name, // Nullable fields don't need 'required'
    required this.imageUrl,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id']?.toString() ??
          'Unknown ID', // Ensure ID is always a String
      name: json['name'].toString(),
      imageUrl: json['imageUrl'].toString(), // Allows null
    );
  }
}
