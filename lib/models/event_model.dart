class EventModel {
  final String id;
  final String name;
  final DateTime date;
  final bool reminderEnabled;
  final int reminderDaysBefore;
  final int reminderHour;
  final int reminderMinute;

  const EventModel({
    required this.id,
    required this.name,
    required this.date,
    this.reminderEnabled = false,
    this.reminderDaysBefore = 0,
    this.reminderHour = 8,
    this.reminderMinute = 0,
  });

  EventModel copyWith({
    String? id,
    String? name,
    DateTime? date,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'reminderEnabled': reminderEnabled,
        'reminderDaysBefore': reminderDaysBefore,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
      };

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as String,
        name: json['name'] as String,
        date: DateTime.parse(json['date'] as String),
        reminderEnabled: json['reminderEnabled'] as bool? ?? false,
        reminderDaysBefore: json['reminderDaysBefore'] as int? ?? 0,
        reminderHour: json['reminderHour'] as int? ?? 8,
        reminderMinute: json['reminderMinute'] as int? ?? 0,
      );

  int get notificationId => id.hashCode.abs() % 2147483647;
}
