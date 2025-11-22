class IdeaModel {
  final String id;
  final String title;
  final String category;
  final String location;

  IdeaModel({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'location': location,
    };
  }

  factory IdeaModel.fromJson(Map<String, dynamic> json) {
    return IdeaModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
    );
  }
}

