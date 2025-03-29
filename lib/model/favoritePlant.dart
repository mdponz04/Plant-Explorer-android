class Favoriteplant {
  final String id;
  final String userName;
  final String plantName;

  Favoriteplant({
    required this.id,
    required this.userName,
    required this.plantName,
  });

  factory Favoriteplant.fromJson(Map<String, dynamic> json) {
    return Favoriteplant(
      id: json['id'] ?? "Unknown ID",
      userName: json['userName'] ?? "Unknown User Name",
      plantName: json['plantName'] ?? "Unknown Plant Name",
    );
  }

  @override
  String toString() {
    return 'Favoriteplant(id: $id, userName: $userName, plantName: $plantName)';
  }
}