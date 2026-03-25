import '../../core/api_client.dart';
import '../../models/mountain.dart';

class MountainRemoteDataSource {
  final ApiClient api;

  MountainRemoteDataSource(this.api);

  /// GET /api/mountains/ — 산 목록 (필터, DRF pagination 전체 순회)
  Future<List<Mountain>> getMountains({String? region, String? difficulty, int? minHeight, int? maxHeight}) async {
    final allResults = <Mountain>[];
    int page = 1;
    bool hasNext = true;

    while (hasNext) {
      final response = await api.get('/mountains/', params: {
        'page': page,
        if (region != null) 'region': region,
        if (difficulty != null) 'difficulty': difficulty,
        if (minHeight != null) 'min_height': minHeight,
        if (maxHeight != null) 'max_height': maxHeight,
      });
      final data = response.data;

      if (data is Map) {
        final results = data['results'] as List? ?? [];
        allResults.addAll(results.map((e) => Mountain.fromJson(e as Map<String, dynamic>)));
        hasNext = data['next'] != null;
        page++;
      } else if (data is List) {
        allResults.addAll(data.map((e) => Mountain.fromJson(e as Map<String, dynamic>)));
        hasNext = false;
      } else {
        hasNext = false;
      }
    }
    return allResults;
  }

  /// GET /api/mountains/recommend/?lat=&lng=&radius=
  Future<List<Mountain>> getRecommended({double? lat, double? lng, double? radius}) async {
    final response = await api.get('/mountains/recommend/', params: {
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (radius != null && radius > 0) 'radius': radius,
    });
    final data = response.data;
    if (data is! List) return [];
    return data.map((e) => Mountain.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/mountains/{id}/
  Future<Mountain> getDetail(String id) async {
    final response = await api.get('/mountains/$id/');
    return Mountain.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/mountains/{id}/courses/ — DRF pagination 대응
  Future<List<Map<String, dynamic>>> getCourses(String mountainId) async {
    final response = await api.get('/mountains/$mountainId/courses/');
    final data = response.data;
    final list = data is Map ? data['results'] as List? ?? [] : data is List ? data : [];
    return list.cast<Map<String, dynamic>>();
  }
}
