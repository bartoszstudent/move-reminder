class ActivityTip {
  final String id;
  final String title;
  final String description;
  final String category;
  final int durationMinutes;
  final int caloriesBurned;
  final String imageUrl;

  ActivityTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.imageUrl,
  });

  factory ActivityTip.fromJson(Map<String, dynamic> json) {
    return ActivityTip(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 15,
      caloriesBurned: json['caloriesBurned'] ?? 100,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
