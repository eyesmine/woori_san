class Stamp {
  final String name;
  final String region;
  final int height;
  bool isStamped;
  bool isTogetherStamped;
  String? stampDate;

  Stamp({
    required this.name,
    required this.region,
    required this.height,
    this.isStamped = false,
    this.isTogetherStamped = false,
    this.stampDate,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'region': region,
    'height': height,
    'isStamped': isStamped,
    'isTogetherStamped': isTogetherStamped,
    'stampDate': stampDate,
  };

  factory Stamp.fromJson(Map<String, dynamic> json) => Stamp(
    name: json['name'],
    region: json['region'],
    height: json['height'],
    isStamped: json['isStamped'] ?? false,
    isTogetherStamped: json['isTogetherStamped'] ?? false,
    stampDate: json['stampDate'],
  );
}

final List<Stamp> defaultStamps = [
  Stamp(name: '북한산', region: '서울', height: 836, isStamped: true, isTogetherStamped: true, stampDate: '2025.01.20'),
  Stamp(name: '관악산', region: '서울', height: 629, isStamped: true, isTogetherStamped: true, stampDate: '2025.02.01'),
  Stamp(name: '청계산', region: '경기', height: 618, isStamped: true, isTogetherStamped: false, stampDate: '2024.11.15'),
  Stamp(name: '도봉산', region: '서울', height: 740, isStamped: true, isTogetherStamped: true, stampDate: '2025.02.10'),
  Stamp(name: '수락산', region: '경기', height: 638, isStamped: true, isTogetherStamped: false, stampDate: '2024.12.05'),
  Stamp(name: '불암산', region: '서울', height: 508),
  Stamp(name: '아차산', region: '서울', height: 285),
  Stamp(name: '용마산', region: '서울', height: 348),
  Stamp(name: '인왕산', region: '서울', height: 338),
  Stamp(name: '삼성산', region: '경기', height: 481),
];
