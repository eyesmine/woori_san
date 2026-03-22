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

    test('toJson/fromJson preserves partner fields', () {
      const user = User(
        id: 'u3',
        email: 'hiker@test.com',
        nickname: '등산러',
        partnerId: 'p123',
        partnerNickname: '파트너닉네임',
      );

      final json = user.toJson();
      final restored = User.fromJson(json);

      expect(restored.partnerId, 'p123');
      expect(restored.partnerNickname, '파트너닉네임');
    });

    test('fromJson handles null partner fields', () {
      const user = User(id: 'u4', email: 'test@test.com', nickname: '테스터');
      final restored = User.fromJson(user.toJson());

      expect(restored.partnerId, isNull);
      expect(restored.partnerNickname, isNull);
    });

    test('fromJson handles snake_case partner fields from backend', () {
      final json = {
        'id': 'u5',
        'email': 'test@test.com',
        'nickname': '테스터',
        'partner_id': '456',
        'partner_nickname': '백엔드파트너',
      };
      final user = User.fromJson(json);

      expect(user.partnerId, '456');
      expect(user.partnerNickname, '백엔드파트너');
    });
  });
}
