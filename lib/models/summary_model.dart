class SummaryModel {
  SummaryModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.date,
    required this.category,
    required this.keywords,
    required this.keyPoints,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String summary;
  final DateTime date;
  final String category;
  final List<String> keywords;
  final List<String> keyPoints;
  bool isFavorite;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "summary": summary,
      "date": date.toIso8601String(),
      "category": category,
      "keywords": keywords,
      "keyPoints": keyPoints,
      "isFavorite": isFavorite,
    };
  }

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      id: json["id"] as String,
      title: json["title"] as String,
      summary: json["summary"] as String,
      date: DateTime.parse(json["date"] as String),
      category: json["category"] as String,
      keywords: List<String>.from(json["keywords"] as List<dynamic>),
      keyPoints: List<String>.from(json["keyPoints"] as List<dynamic>),
      isFavorite: json["isFavorite"] as bool? ?? false,
    );
  }
}
