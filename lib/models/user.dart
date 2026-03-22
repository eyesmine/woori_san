class User {
  final String id;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final String? partnerId;
  final String? partnerNickname;

  const User({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    this.createdAt,
    this.partnerId,
    this.partnerNickname,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nickname': nickname,
    'profileImageUrl': profileImageUrl,
    'createdAt': createdAt?.toIso8601String(),
    'partnerId': partnerId,
    'partnerNickname': partnerNickname,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id']?.toString() ?? '',
    email: json['email'] ?? '',
    nickname: json['nickname'] ?? '',
    profileImageUrl: json['profile_image'] ?? json['profileImageUrl'],
    createdAt: (json['created_at'] ?? json['createdAt']) != null
        ? DateTime.tryParse((json['created_at'] ?? json['createdAt']).toString())
        : null,
    partnerId: json['partner_id']?.toString() ?? json['partnerId']?.toString(),
    partnerNickname: json['partner_nickname'] ?? json['partnerNickname'],
  );
}
