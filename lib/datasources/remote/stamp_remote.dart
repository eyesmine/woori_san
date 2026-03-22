import '../../core/api_client.dart';
import '../../models/stamp.dart';

class StampRemoteDataSource {
  final ApiClient api;

  StampRemoteDataSource(this.api);

  /// GET /api/stamps/ — DRF pagination 대응
  Future<List<Stamp>> getStamps() async {
    final response = await api.get('/stamps/');
    final data = response.data;
    final list = data is Map ? data['results'] as List? ?? [] : data is List ? data : [];
    return list.map((e) => Stamp.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /api/stamps/ — 도장 찍기 (GPS 정상 100m 이내 검증)
  Future<void> createStamp(Map<String, dynamic> data) async {
    await api.post('/stamps/', data: data);
  }

  /// GET /api/stamps/together/ — DRF pagination 대응
  Future<List<Stamp>> getTogetherStamps() async {
    final response = await api.get('/stamps/together/');
    final data = response.data;
    final list = data is Map ? data['results'] as List? ?? [] : data is List ? data : [];
    return list.map((e) => Stamp.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/stamps/progress/ — 100대 명산 진행률
  Future<Map<String, dynamic>> getProgress() async {
    final response = await api.get('/stamps/progress/');
    final data = response.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw FormatException('Unexpected progress response type: ${data.runtimeType}');
  }
}
