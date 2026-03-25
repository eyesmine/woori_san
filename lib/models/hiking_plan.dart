enum PlanStatus {
  confirmed,
  pending,
  done;

  static PlanStatus fromString(String s) {
    return PlanStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => PlanStatus.pending,
    );
  }
}

class HikingPlan {
  final String id;
  final String mountain;
  final int? mountainId;
  final String date;
  final PlanStatus status;
  final String emoji;
  final String? memo;

  HikingPlan({
    String? id,
    required this.mountain,
    this.mountainId,
    required this.date,
    required this.status,
    required this.emoji,
    this.memo,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  HikingPlan copyWith({
    String? id,
    String? mountain,
    int? mountainId,
    String? date,
    PlanStatus? status,
    String? emoji,
    String? memo,
  }) {
    return HikingPlan(
      id: id ?? this.id,
      mountain: mountain ?? this.mountain,
      mountainId: mountainId ?? this.mountainId,
      date: date ?? this.date,
      status: status ?? this.status,
      emoji: emoji ?? this.emoji,
      memo: memo ?? this.memo,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mountain': mountainId ?? mountain,
    'planned_at': date,
    'status': status.name,
    'memo': memo ?? '',
    'emoji': emoji,
  };

  factory HikingPlan.fromJson(Map<String, dynamic> json) => HikingPlan(
    id: json['id']?.toString(),
    mountain: json['mountain_name'] ?? json['mountain']?.toString() ?? '',
    mountainId: json['mountain'] is int ? json['mountain'] : null,
    date: json['planned_at'] ?? json['date'] ?? '',
    status: PlanStatus.fromString(json['status'] ?? 'pending'),
    emoji: json['emoji'] ?? '🏔️',
    memo: json['memo'],
  );
}

class ChecklistItem {
  final String text;
  bool checked;

  ChecklistItem({required this.text, this.checked = false});

  Map<String, dynamic> toJson() => {'text': text, 'checked': checked};

  factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
      ChecklistItem(
        text: json['text'] ?? json['label'] ?? '',
        checked: json['checked'] ?? json['is_checked'] ?? false,
      );
}

final List<ChecklistItem> defaultChecklist = [
  ChecklistItem(text: '등산화'),
  ChecklistItem(text: '물 (500ml × 2)'),
  ChecklistItem(text: '간식 (에너지바, 견과류)'),
  ChecklistItem(text: '방풍자켓'),
  ChecklistItem(text: '스틱'),
  ChecklistItem(text: '구급약'),
];
