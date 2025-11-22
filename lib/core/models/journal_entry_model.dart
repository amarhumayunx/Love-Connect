class JournalEntryModel {
  final String id;
  final DateTime date;
  final String note;

  JournalEntryModel({
    required this.id,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String,
    );
  }

  JournalEntryModel copyWith({
    String? id,
    DateTime? date,
    String? note,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}

