class EventModel {
  final String id;
  final String name;
  final DateTime date;

  const EventModel({
    required this.id,
    required this.name,
    required this.date,
  });

  EventModel copyWith({String? id, String? name, DateTime? date}) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
      };

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as String,
        name: json['name'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}
