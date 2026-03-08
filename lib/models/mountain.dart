import 'package:flutter/material.dart';

class Mountain {
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
}

final List<Mountain> sampleMountains = [
  Mountain(
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

// 100대 명산 도장 데이터
class StampMountain {
  final String name;
  final String region;
  final int height;
  final bool isStamped;
  final bool isTogetherStamped;
  final String? stampDate;

  const StampMountain({
    required this.name,
    required this.region,
    required this.height,
    required this.isStamped,
    required this.isTogetherStamped,
    this.stampDate,
  });
}

final List<StampMountain> stampMountains = [
  StampMountain(name: '북한산', region: '서울', height: 836, isStamped: true, isTogetherStamped: true, stampDate: '2025.01.20'),
  StampMountain(name: '관악산', region: '서울', height: 629, isStamped: true, isTogetherStamped: true, stampDate: '2025.02.01'),
  StampMountain(name: '청계산', region: '경기', height: 618, isStamped: true, isTogetherStamped: false, stampDate: '2024.11.15'),
  StampMountain(name: '도봉산', region: '서울', height: 740, isStamped: true, isTogetherStamped: true, stampDate: '2025.02.10'),
  StampMountain(name: '수락산', region: '경기', height: 638, isStamped: true, isTogetherStamped: false, stampDate: '2024.12.05'),
  StampMountain(name: '불암산', region: '서울', height: 508, isStamped: false, isTogetherStamped: false),
  StampMountain(name: '아차산', region: '서울', height: 285, isStamped: false, isTogetherStamped: false),
  StampMountain(name: '용마산', region: '서울', height: 348, isStamped: false, isTogetherStamped: false),
  StampMountain(name: '인왕산', region: '서울', height: 338, isStamped: false, isTogetherStamped: false),
  StampMountain(name: '삼성산', region: '경기', height: 481, isStamped: false, isTogetherStamped: false),
];