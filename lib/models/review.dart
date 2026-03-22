class Review {
  final String id;
  final String mountainId;
  final String userId;
  final String userNickname;
  final String? userProfileImageUrl;
  final String content;
  final List<String> photoUrls;
  final double? rating;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.mountainId,
    required this.userId,
    required this.userNickname,
    this.userProfileImageUrl,
    required this.content,
    this.photoUrls = const [],
    this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'mountain_id': mountainId,
    'user_id': userId,
    'user_nickname': userNickname,
    'profile_image': userProfileImageUrl,
    'content': content,
    'photo_urls': photoUrls,
    'rating': rating,
    'created_at': createdAt.toIso8601String(),
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'].toString(),
    mountainId: json['mountain_id'].toString(),
    userId: json['user_id'].toString(),
    userNickname: json['user_nickname'] ?? '',
    userProfileImageUrl: json['profile_image'],
    content: json['content'] ?? '',
    photoUrls: (json['photo_urls'] as List?)
        ?.map((e) => e.toString())
        .toList() ?? [],
    rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
  );
}
