class Anime {
  final String id;
  final String title;
  final String imageUrl;
  final String status;
  final String category; // Essential for the badge

  Anime({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.category,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
      status: json['status'] ?? 'watching',
      category: json['category'] ?? 'Action', // Matches seed.js
    );
  }
}
