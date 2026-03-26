class HikingRecord {
  final String id;
  final String mountain;
  final String date;
  final String duration;
  final double distanceKm;
  final String emoji;
  final String? mountainId;
  final List<Map<String, double>>? routePoints;
  final List<String>? photoUrls;
  final int? elevationGain;
  final DateTime? startTime;
  final DateTime? endTime;

  HikingRecord({
    String? id,
    required this.mountain,
    required this.date,
    required this.duration,
    required this.distanceKm,
    required this.emoji,
    this.mountainId,
    this.routePoints,
    this.photoUrls,
    this.elevationGain,
    this.startTime,
    this.endTime,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  String get distance => '${distanceKm}km';

  List<double> get elevations =>
      routePoints?.map((p) => (p['alt'] as num?)?.toDouble() ?? 0.0).toList() ?? [];

  HikingRecord copyWith({
    String? id,
    String? mountain,
    String? date,
    String? duration,
    double? distanceKm,
    String? emoji,
    String? mountainId,
    List<Map<String, double>>? routePoints,
    List<String>? photoUrls,
    int? elevationGain,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return HikingRecord(
      id: id ?? this.id,
      mountain: mountain ?? this.mountain,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      distanceKm: distanceKm ?? this.distanceKm,
      emoji: emoji ?? this.emoji,
      mountainId: mountainId ?? this.mountainId,
      routePoints: routePoints ?? this.routePoints,
      photoUrls: photoUrls ?? this.photoUrls,
      elevationGain: elevationGain ?? this.elevationGain,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mountain': mountain,
    'date': date,
    'duration': duration,
    'distanceKm': distanceKm,
    'emoji': emoji,
    if (mountainId != null) 'mountainId': mountainId,
    if (routePoints != null) 'routePoints': routePoints,
    if (photoUrls != null) 'photoUrls': photoUrls,
    if (elevationGain != null) 'elevationGain': elevationGain,
    if (startTime != null) 'startTime': startTime!.toIso8601String(),
    if (endTime != null) 'endTime': endTime!.toIso8601String(),
  };

  factory HikingRecord.fromJson(Map<String, dynamic> json) {
    var distanceKm = json['distanceKm'] != null
        ? (json['distanceKm'] as num).toDouble()
        : double.tryParse((json['distance'] as String? ?? '').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    // 음수 값 방어
    if (distanceKm < 0) distanceKm = 0;

    final elevationGain = json['elevationGain'] as int?;

    return HikingRecord(
      id: json['id'],
      mountain: json['mountain'] ?? '알 수 없음',
      date: json['date'] ?? '',
      duration: json['duration'] ?? '0m 0s',
      distanceKm: distanceKm,
      emoji: json['emoji'] ?? '🏔️',
      mountainId: json['mountainId'],
      routePoints: (json['routePoints'] as List?)
          ?.map((p) {
            try {
              return Map<String, double>.from((p as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())));
            } catch (_) {
              return <String, double>{};
            }
          })
          .where((p) => p.isNotEmpty)
          .toList(),
      photoUrls: (json['photoUrls'] as List?)?.cast<String>(),
      elevationGain: elevationGain != null && elevationGain < 0 ? 0 : elevationGain,
      startTime: json['startTime'] != null ? DateTime.tryParse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
    );
  }
}
