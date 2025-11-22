class UserProfileModel {
  final String name;
  final String about;

  UserProfileModel({
    required this.name,
    required this.about,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'about': about,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] as String? ?? 'User',
      about: json['about'] as String? ?? 'Keeping the love story alive.',
    );
  }

  UserProfileModel copyWith({
    String? name,
    String? about,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      about: about ?? this.about,
    );
  }
}

