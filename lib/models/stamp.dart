class Stamp {
  final String name;
  final String region;
  final int height;
  final bool isStamped;
  final bool isTogetherStamped;
  final String? stampDate;

  const Stamp({
    required this.name,
    required this.region,
    required this.height,
    this.isStamped = false,
    this.isTogetherStamped = false,
    this.stampDate,
  });

  Stamp copyWith({
    String? name,
    String? region,
    int? height,
    bool? isStamped,
    bool? isTogetherStamped,
    String? stampDate,
    bool clearStampDate = false,
  }) {
    return Stamp(
      name: name ?? this.name,
      region: region ?? this.region,
      height: height ?? this.height,
      isStamped: isStamped ?? this.isStamped,
      isTogetherStamped: isTogetherStamped ?? this.isTogetherStamped,
      stampDate: clearStampDate ? null : (stampDate ?? this.stampDate),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stamp &&
          name == other.name &&
          region == other.region &&
          height == other.height &&
          isStamped == other.isStamped &&
          isTogetherStamped == other.isTogetherStamped &&
          stampDate == other.stampDate;

  @override
  int get hashCode => Object.hash(name, region, height, isStamped, isTogetherStamped, stampDate);

  Map<String, dynamic> toJson() => {
    'name': name,
    'region': region,
    'height': height,
    'isStamped': isStamped,
    'isTogetherStamped': isTogetherStamped,
    'stampDate': stampDate,
  };

  factory Stamp.fromJson(Map<String, dynamic> json) => Stamp(
    name: json['mountain_name'] ?? json['name'] ?? '',
    region: json['region'] ?? '',
    height: json['height'] ?? 0,
    isStamped: json['isStamped'] ?? (json['stamped_at'] != null),
    isTogetherStamped: json['isTogetherStamped'] ?? json['is_together'] ?? false,
    stampDate: json['stampDate'] ?? json['stamped_at']?.toString().substring(0, 10),
  );
}

final List<Stamp> defaultStamps = [
  // 1-5: stamped for demo
  Stamp(name: '가리산', region: '강원 홍천', height: 1051, isStamped: true, isTogetherStamped: true, stampDate: '2025.01.15'),
  Stamp(name: '가리왕산', region: '강원 정선/평창', height: 1561, isStamped: true, isTogetherStamped: false, stampDate: '2025.02.01'),
  Stamp(name: '가야산', region: '경남 합천/경북 성주', height: 1430, isStamped: true, isTogetherStamped: true, stampDate: '2025.02.15'),
  Stamp(name: '감악산', region: '경기 파주/연천', height: 675, isStamped: true, isTogetherStamped: false, stampDate: '2025.03.01'),
  Stamp(name: '강천산', region: '전북 순창', height: 584, isStamped: true, isTogetherStamped: true, stampDate: '2025.03.10'),
  // 6-100: unstamped
  Stamp(name: '계룡산', region: '충남 공주/논산', height: 845),
  Stamp(name: '계방산', region: '강원 홍천/평창', height: 1577),
  Stamp(name: '공작산', region: '강원 홍천', height: 887),
  Stamp(name: '관악산', region: '서울 관악', height: 629),
  Stamp(name: '구병산', region: '충북 보은', height: 876),
  Stamp(name: '금산', region: '경남 남해', height: 681),
  Stamp(name: '금수산', region: '충북 제천', height: 1016),
  Stamp(name: '금오산', region: '경북 구미', height: 976),
  Stamp(name: '금정산', region: '부산 금정', height: 801),
  Stamp(name: '깃대봉', region: '전남 신안 홍도', height: 368),
  Stamp(name: '남산', region: '경북 경주', height: 468),
  Stamp(name: '내연산', region: '경북 포항', height: 710),
  Stamp(name: '내장산', region: '전북 정읍', height: 763),
  Stamp(name: '덕숭산', region: '충남 예산', height: 495),
  Stamp(name: '덕유산', region: '전북 무주/경남 거창', height: 1614),
  Stamp(name: '덕항산', region: '강원 삼척/태백', height: 1071),
  Stamp(name: '도락산', region: '충북 단양', height: 964),
  Stamp(name: '두륜산', region: '전남 해남', height: 703),
  Stamp(name: '두타산', region: '강원 삼척/동해', height: 1353),
  Stamp(name: '마니산', region: '인천 강화', height: 472),
  Stamp(name: '마이산', region: '전북 진안', height: 686),
  Stamp(name: '명성산', region: '경기 포천/강원 철원', height: 923),
  Stamp(name: '명지산', region: '경기 가평', height: 1267),
  Stamp(name: '모악산', region: '전북 전주/김제', height: 794),
  Stamp(name: '무등산', region: '광주/전남 화순/담양', height: 1187),
  Stamp(name: '무학산', region: '경남 마산', height: 761),
  Stamp(name: '미륵산', region: '경남 통영', height: 461),
  Stamp(name: '민주지산', region: '충북 영동/전북 무주', height: 1242),
  Stamp(name: '방장산', region: '전북 고창/전남 장성', height: 743),
  Stamp(name: '방태산', region: '강원 인제', height: 1444),
  Stamp(name: '백덕산', region: '강원 영월/평창', height: 1350),
  Stamp(name: '백암산', region: '전남 장성', height: 741),
  Stamp(name: '백운산 (광양)', region: '전남 광양', height: 1218),
  Stamp(name: '백운산 (포천)', region: '경기 포천', height: 904),
  Stamp(name: '북한산', region: '서울', height: 836),
  Stamp(name: '비슬산', region: '대구 달성', height: 1084),
  Stamp(name: '사량도 지리산', region: '경남 통영 사량도', height: 398),
  Stamp(name: '삼악산', region: '강원 춘천', height: 654),
  Stamp(name: '선운산', region: '전북 고창', height: 336),
  Stamp(name: '설악산', region: '강원 속초/인제/양양', height: 1708),
  Stamp(name: '소백산', region: '충북 단양/경북 영주', height: 1440),
  Stamp(name: '소요산', region: '경기 동두천', height: 587),
  Stamp(name: '속리산', region: '충북 보은', height: 1058),
  Stamp(name: '수락산', region: '서울 노원', height: 638),
  Stamp(name: '신불산', region: '울산', height: 1159),
  Stamp(name: '연인산', region: '경기 가평', height: 1068),
  Stamp(name: '오대산', region: '강원 홍천/평창', height: 1563),
  Stamp(name: '오봉산', region: '강원 춘천', height: 779),
  Stamp(name: '용문산', region: '경기 양평', height: 1157),
  Stamp(name: '용화산', region: '강원 춘천/화천', height: 878),
  Stamp(name: '운문산', region: '경북 청도', height: 1188),
  Stamp(name: '운악산', region: '경기 포천/가평', height: 936),
  Stamp(name: '운장산', region: '전북 진안', height: 1126),
  Stamp(name: '월악산', region: '충북 제천/충주', height: 1097),
  Stamp(name: '월출산', region: '전남 영암', height: 809),
  Stamp(name: '유명산', region: '경기 양평/가평', height: 862),
  Stamp(name: '응봉산', region: '강원 삼척', height: 999),
  Stamp(name: '장안산', region: '전북 장수', height: 1237),
  Stamp(name: '재약산', region: '경남 밀양', height: 1189),
  Stamp(name: '적상산', region: '전북 무주', height: 1034),
  Stamp(name: '점봉산', region: '강원 인제/양양', height: 1424),
  Stamp(name: '조계산', region: '전남 순천', height: 884),
  Stamp(name: '주왕산', region: '경북 청송', height: 721),
  Stamp(name: '주흘산', region: '경북 문경', height: 1106),
  Stamp(name: '지리산', region: '전남/경남/전북', height: 1915),
  Stamp(name: '천관산', region: '전남 장흥', height: 723),
  Stamp(name: '천마산', region: '경기 남양주', height: 812),
  Stamp(name: '천성산', region: '경남 양산', height: 922),
  Stamp(name: '천태산', region: '충북 영동', height: 715),
  Stamp(name: '청계산', region: '서울/경기', height: 618),
  Stamp(name: '청량산', region: '경북 봉화', height: 870),
  Stamp(name: '추월산', region: '전남 담양', height: 731),
  Stamp(name: '축령산', region: '전남 장성', height: 621),
  Stamp(name: '치악산', region: '강원 원주', height: 1288),
  Stamp(name: '칠갑산', region: '충남 청양', height: 561),
  Stamp(name: '태백산', region: '강원 태백/영월', height: 1567),
  Stamp(name: '태화산', region: '강원 영월', height: 1027),
  Stamp(name: '팔공산', region: '대구/경북 칠곡', height: 1193),
  Stamp(name: '팔봉산', region: '강원 홍천', height: 328),
  Stamp(name: '팔영산', region: '전남 고흥', height: 609),
  Stamp(name: '한라산', region: '제주', height: 1950),
  Stamp(name: '함백산', region: '강원 태백/정선', height: 1573),
  Stamp(name: '화악산', region: '경기 가평/강원 춘천', height: 1468),
  Stamp(name: '화왕산', region: '경남 창녕', height: 757),
  Stamp(name: '황매산', region: '경남 합천/산청', height: 1108),
  Stamp(name: '황석산', region: '경남 함양', height: 1190),
  Stamp(name: '황악산', region: '경북 김천', height: 1111),
  Stamp(name: '희양산', region: '경북 문경/충북 괴산', height: 999),
  Stamp(name: '가지산', region: '울산/경남', height: 1241),
  Stamp(name: '대둔산', region: '충남 논산/전북 완주', height: 878),
  Stamp(name: '대암산', region: '강원 인제', height: 1304),
  Stamp(name: '도봉산', region: '서울/경기 양주', height: 740),
  Stamp(name: '불암산', region: '서울/경기 남양주', height: 508),
  Stamp(name: '아차산', region: '서울', height: 285),
  Stamp(name: '가리봉', region: '강원 인제/양양', height: 1519),
];
