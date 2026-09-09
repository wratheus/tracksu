final class EarnedMedal {
  const EarnedMedal({
    required this.id,
    required this.earnedAt,
    this.name,
    this.description,
    this.imageUri,
  });
  final int id;
  final DateTime earnedAt;
  final String? name;
  final String? description;
  final Uri? imageUri;
}
