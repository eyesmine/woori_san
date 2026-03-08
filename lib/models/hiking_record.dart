class HikingRecord {
  final String id;
  final String mountain;
  final String date;
  final String duration;
  final String distance;
  final String emoji;

  HikingRecord({
    String? id,
    required this.mountain,
    required this.date,
    required this.duration,
    required this.distance,
    required this.emoji,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'mountain': mountain,
    'date': date,
    'duration': duration,
    'distance': distance,
    'emoji': emoji,
  };

  factory HikingRecord.fromJson(Map<String, dynamic> json) => HikingRecord(
    id: json['id'],
    mountain: json['mountain'],
    date: json['date'],
    duration: json['duration'],
    distance: json['distance'],
    emoji: json['emoji'],
  );
}
