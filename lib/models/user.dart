class User {
  final String id;
  final String nickname;
  final String? profileImageUrl;

  const User({
    required this.id,
    required this.nickname,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'profileImageUrl': profileImageUrl,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    nickname: json['nickname'],
    profileImageUrl: json['profileImageUrl'],
  );
}
