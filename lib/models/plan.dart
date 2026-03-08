enum PlanStatus { confirmed, pending }

class Plan {
  final String id;
  final String mountain;
  final String date;
  final PlanStatus status;
  final String emoji;

  Plan({
    String? id,
    required this.mountain,
    required this.date,
    required this.status,
    required this.emoji,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'mountain': mountain,
    'date': date,
    'status': status.name,
    'emoji': emoji,
  };

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    id: json['id'],
    mountain: json['mountain'],
    date: json['date'],
    status: PlanStatus.values.byName(json['status']),
    emoji: json['emoji'],
  );
}

class ChecklistItem {
  final String text;
  bool checked;

  ChecklistItem({required this.text, required this.checked});

  Map<String, dynamic> toJson() => {'text': text, 'checked': checked};

  factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
      ChecklistItem(text: json['text'], checked: json['checked']);
}

final List<ChecklistItem> defaultChecklist = [
  ChecklistItem(text: '등산화', checked: false),
  ChecklistItem(text: '물 (500ml × 2)', checked: false),
  ChecklistItem(text: '간식 (에너지바, 견과류)', checked: false),
  ChecklistItem(text: '방풍자켓', checked: false),
  ChecklistItem(text: '스틱', checked: false),
  ChecklistItem(text: '구급약', checked: false),
];
