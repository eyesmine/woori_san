import 'package:flutter_test/flutter_test.dart';
import 'package:woori_san/models/user.dart';

void main() {
  group('User', () {
    test('toJson/fromJson round trip with all fields', () {
      final user = User(
        id: 'u1',
        email: 'hiker@mountain.com',
        nickname: '등산왕',
        profileImageUrl: 'https://example.com/pic.jpg',
        createdAt: DateTime(2025, 1, 1),
      );

      final json = user.toJson();
      final restored = User.fromJson(json);

      expect(restored.id, 'u1');
      expect(restored.email, 'hiker@mountain.com');
      expect(restored.nickname, '등산왕');
      expect(restored.profileImageUrl, 'https://example.com/pic.jpg');
      expect(restored.createdAt, DateTime(2025, 1, 1));
    });

    test('toJson/fromJson handles null optional fields', () {
      const user = User(id: 'u2', email: 'test@test.com', nickname: '테스터');

      final json = user.toJson();
      expect(json['profileImageUrl'], isNull);
      expect(json['createdAt'], isNull);

      final restored = User.fromJson(json);
      expect(restored.profileImageUrl, isNull);
      expect(restored.createdAt, isNull);
    });
  });
}
