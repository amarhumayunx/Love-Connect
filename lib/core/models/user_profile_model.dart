class UserProfileModel {
  final String name;
  final String about;
  final String? profilePictureUrl;
  final String? email;
  final String? gender;

  UserProfileModel({
    required this.name,
    required this.about,
    this.profilePictureUrl,
    this.email,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'about': about,
      'profilePictureUrl': profilePictureUrl,
      'email': email,
      'gender': gender,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] as String? ?? 'User',
      about: json['about'] as String? ?? 'Keeping the love story alive.',
      profilePictureUrl: json['profilePictureUrl'] as String?,
      email: json['email'] as String?,
      gender: json['gender'] as String?,
    );
  }

  UserProfileModel copyWith({
    String? name,
    String? about,
    String? profilePictureUrl,
    String? email,
    String? gender,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      about: about ?? this.about,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      email: email ?? this.email,
      gender: gender ?? this.gender,
    );
  }
}
