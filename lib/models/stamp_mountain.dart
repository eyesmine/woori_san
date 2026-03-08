class StampMountain {
  final String name;
  final String region;
  final int height;
  bool isStamped;
  bool isTogetherStamped;
  String? stampDate;

  StampMountain({
    required this.name,
    required this.region,
    required this.height,
    required this.isStamped,
    required this.isTogetherStamped,
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

  factory StampMountain.fromJson(Map<String, dynamic> json) => StampMountain(
    name: json['name'],
    region: json['region'],
    height: json['height'],
    isStamped: json['isStamped'],
    isTogetherStamped: json['isTogetherStamped'],
    stampDate: json['stampDate'],
  );

  StampMountain copyWith({
    bool? isStamped,
    bool? isTogetherStamped,
    String? stampDate,
  }) => StampMountain(
    name: name,
    region: region,
    height: height,
    isStamped: isStamped ?? this.isStamped,
    isTogetherStamped: isTogetherStamped ?? this.isTogetherStamped,
    stampDate: stampDate ?? this.stampDate,
  );
}

List<StampMountain> defaultStampMountains = [
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
