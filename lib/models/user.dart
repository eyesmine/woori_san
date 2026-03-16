class User {
  final String id;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nickname': nickname,
    'profileImageUrl': profileImageUrl,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    nickname: json['nickname'],
    profileImageUrl: json['profileImageUrl'],
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}
