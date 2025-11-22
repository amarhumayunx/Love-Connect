class AddPlanModel {
  final String title;
  final DateTime date;
  final DateTime? time;
  final String place;
  final String type;

  AddPlanModel({
    this.title = '',
    DateTime? date,
    this.time,
    this.place = '',
    this.type = 'Surprise',
  }) : date = date ?? DateTime.now();

  AddPlanModel copyWith({
    String? title,
    DateTime? date,
    DateTime? time,
    String? place,
    String? type,
  }) {
    return AddPlanModel(
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      place: place ?? this.place,
      type: type ?? this.type,
    );
  }
}

