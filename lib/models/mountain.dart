import 'package:flutter/material.dart';

class Mountain {
  final String id;
  final String name;
  final String location;
  final String difficulty;
  final String time;
  final String distance;
  final int height;
  final String emoji;
  final List<Color> colors;
  final String description;

  const Mountain({
    required this.id,
    required this.name,
    required this.location,
    required this.difficulty,
    required this.time,
    required this.distance,
    required this.height,
    required this.emoji,
    required this.colors,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'difficulty': difficulty,
    'time': time,
    'distance': distance,
    'height': height,
    'emoji': emoji,
    'colors': colors.map((c) => c.toARGB32()).toList(),
    'description': description,
  };

  factory Mountain.fromJson(Map<String, dynamic> json) => Mountain(
    id: json['id'],
    name: json['name'],
    location: json['location'],
    difficulty: json['difficulty'],
    time: json['time'],
    distance: json['distance'],
    height: json['height'],
    emoji: json['emoji'],
    colors: (json['colors'] as List).map((c) => Color(c as int)).toList(),
    description: json['description'],
  );
}

final List<Mountain> defaultMountains = [
  Mountain(
    id: 'mt_1',
    name: '청계산',
    location: '서울/경기',
    difficulty: '초급',
    time: '약 3시간',
    distance: '6.5km',
    height: 618,
    emoji: '🌲',
    colors: [const Color(0xFF52B788), const Color(0xFF2D6A4F)],
    description: '서울 근교에서 가장 인기 있는 초급 코스. 정상에서 서울 전경이 펼쳐져요.',
  ),
  Mountain(
    id: 'mt_2',
    name: '북한산',
    location: '서울',
    difficulty: '중급',
    time: '약 5시간',
    distance: '9.2km',
    height: 836,
    emoji: '⛰️',
    colors: [const Color(0xFF74B3CE), const Color(0xFF1B4332)],
    description: '서울의 상징적인 명산. 백운대 정상에서의 뷰는 잊을 수 없어요.',
  ),
  Mountain(
    id: 'mt_3',
    name: '관악산',
    location: '서울',
    difficulty: '중급',
    time: '약 4시간',
    distance: '7.8km',
    height: 629,
    emoji: '🌄',
    colors: [const Color(0xFFFF8C42), const Color(0xFFB5451B)],
    description: '가을 단풍이 아름다운 산. 연주대에서 보는 일몰은 정말 특별해요.',
  ),
  Mountain(
    id: 'mt_4',
    name: '수락산',
    location: '노원',
    difficulty: '초급',
    time: '약 3시간',
    distance: '5.5km',
    height: 638,
    emoji: '🍃',
    colors: [const Color(0xFF95D5B2), const Color(0xFF40916C)],
    description: '계곡이 아름다워 여름에 특히 인기. 초보자도 쉽게 오를 수 있어요.',
  ),
];
