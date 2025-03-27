class Plant {
  final String id;
  final String name;
  final String scientificName;
  final String family;
  final String description;
  final String habitat;
  final String distribution;

  Plant({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.family,
    required this.description,
    required this.habitat,
    required this.distribution,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] ?? "Unknown ID",
      name: json['name'] ?? "Unknown Name",
      scientificName: json['scientificName'] ?? "Unknown Scientific Name",
      family: json['family'] ?? "Unknown Family",
      description: json['description'] ?? "No description available",
      habitat: json['habitat'] ?? "Unknown Habitat",
      distribution: json['distribution'] ?? "Unknown Distribution",
    );
  }
}
