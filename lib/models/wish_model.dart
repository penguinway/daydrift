enum WishStatus { todo, planning, completed }

class WishModel {
  final String id;
  final String title;
  final String? description;
  final String category;
  final DateTime? targetDate;
  final WishStatus status;
  final DateTime createdAt;

  const WishModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.targetDate,
    this.status = WishStatus.todo,
    required this.createdAt,
  });

  WishModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? targetDate,
    WishStatus? status,
    DateTime? createdAt,
    bool clearDescription = false,
    bool clearTargetDate = false,
  }) {
    return WishModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      category: category ?? this.category,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'targetDate': targetDate?.toIso8601String(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WishModel.fromJson(Map<String, dynamic> json) => WishModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        category: json['category'] as String,
        targetDate: json['targetDate'] != null
            ? DateTime.parse(json['targetDate'] as String)
            : null,
        status: WishStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
