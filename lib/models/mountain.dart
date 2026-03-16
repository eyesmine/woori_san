import 'package:flutter/material.dart';

enum Difficulty {
  beginner('초급'),
  intermediate('중급'),
  advanced('상급');

  final String label;
  const Difficulty(this.label);

  Color get color {
    return switch (this) {
      Difficulty.beginner => Colors.green,
      Difficulty.intermediate => Colors.orange,
      Difficulty.advanced => Colors.red,
    };
  }

  static Difficulty fromLabel(String label) {
    return Difficulty.values.firstWhere(
      (d) => d.label == label,
      orElse: () => Difficulty.intermediate,
    );
  }
}

class Mountain {
  final String id;
  final String name;
  final String location;
  final Difficulty difficulty;
  final String time;
  final double distanceKm;
  final int height;
  final String emoji;
  final List<Color> colors;
  final String description;
  final double latitude;
  final double longitude;
  final String? imageUrl;

  const Mountain({
    required this.id,
    required this.name,
    required this.location,
    required this.difficulty,
    required this.time,
    required this.distanceKm,
    required this.height,
    required this.emoji,
    required this.colors,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
  });

  String get distance => '${distanceKm}km';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'difficulty': difficulty.label,
    'time': time,
    'distanceKm': distanceKm,
    'height': height,
    'emoji': emoji,
    'colors': colors.map((c) => c.toARGB32()).toList(),
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'imageUrl': imageUrl,
  };

  factory Mountain.fromJson(Map<String, dynamic> json) {
    final distanceKm = json['distanceKm'] != null
        ? (json['distanceKm'] as num).toDouble()
        : double.tryParse((json['distance'] as String? ?? '').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    return Mountain(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      difficulty: Difficulty.fromLabel(json['difficulty']),
      time: json['time'],
      distanceKm: distanceKm,
      height: json['height'],
      emoji: json['emoji'],
      colors: (json['colors'] as List).map((c) => Color(c as int)).toList(),
      description: json['description'],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'],
    );
  }
}

final List<Mountain> defaultMountains = [
  Mountain(
    id: 'mt_1',
    name: '청계산',
    location: '서울/경기',
    difficulty: Difficulty.beginner,
    time: '약 3시간',
    distanceKm: 6.5,
    height: 618,
    emoji: '🌲',
    colors: [const Color(0xFF52B788), const Color(0xFF2D6A4F)],
    description: '서울 근교에서 가장 인기 있는 초급 코스. 정상에서 서울 전경이 펼쳐져요.',
    latitude: 37.4437,
    longitude: 127.0557,
  ),
  Mountain(
    id: 'mt_2',
    name: '북한산',
    location: '서울',
    difficulty: Difficulty.intermediate,
    time: '약 5시간',
    distanceKm: 9.2,
    height: 836,
    emoji: '⛰️',
    colors: [const Color(0xFF74B3CE), const Color(0xFF1B4332)],
    description: '서울의 상징적인 명산. 백운대 정상에서의 뷰는 잊을 수 없어요.',
    latitude: 37.6584,
    longitude: 126.9780,
  ),
  Mountain(
    id: 'mt_3',
    name: '관악산',
    location: '서울',
    difficulty: Difficulty.intermediate,
    time: '약 4시간',
    distanceKm: 7.8,
    height: 629,
    emoji: '🌄',
    colors: [const Color(0xFFFF8C42), const Color(0xFFB5451B)],
    description: '가을 단풍이 아름다운 산. 연주대에서 보는 일몰은 정말 특별해요.',
    latitude: 37.4331,
    longitude: 126.9637,
  ),
  Mountain(
    id: 'mt_4',
    name: '수락산',
    location: '노원',
    difficulty: Difficulty.beginner,
    time: '약 3시간',
    distanceKm: 5.5,
    height: 638,
    emoji: '🍃',
    colors: [const Color(0xFF95D5B2), const Color(0xFF40916C)],
    description: '계곡이 아름다워 여름에 특히 인기. 초보자도 쉽게 오를 수 있어요.',
    latitude: 37.6720,
    longitude: 127.0726,
  ),
];
