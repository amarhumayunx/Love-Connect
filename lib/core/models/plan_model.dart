class PlanModel {
  final String id;
  final String title;
  final DateTime date;
  final DateTime? time;
  final String place;
  final PlanType type;

  PlanModel({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    required this.place,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': time?.toIso8601String(),
      'place': place,
      'type': type.toString().split('.').last,
    };
  }

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] != null ? DateTime.parse(json['time'] as String) : null,
      place: json['place'] as String,
      type: PlanType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PlanType.surprise,
      ),
    );
  }

  PlanModel copyWith({
    String? id,
    String? title,
    DateTime? date,
    DateTime? time,
    String? place,
    PlanType? type,
  }) {
    return PlanModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      place: place ?? this.place,
      type: type ?? this.type,
    );
  }
}

enum PlanType {
  dinner,
  movie,
  surprise,
  walk,
  trip,
  other,
}

extension PlanTypeExtension on PlanType {
  String get displayName {
    switch (this) {
      case PlanType.dinner:
        return 'DINNER';
      case PlanType.movie:
        return 'MOVIE';
      case PlanType.surprise:
        return 'SURPRISE';
      case PlanType.walk:
        return 'WALK';
      case PlanType.trip:
        return 'TRIP';
      case PlanType.other:
        return 'OTHER';
    }
  }
}

