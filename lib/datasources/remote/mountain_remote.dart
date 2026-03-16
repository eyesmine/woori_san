import '../../core/api_client.dart';
import '../../models/mountain.dart';

class MountainRemoteDataSource {
  final ApiClient api;

  MountainRemoteDataSource(this.api);

  Future<List<Mountain>> getRecommended() async {
    final response = await api.get('/mountains/recommended');
    final data = response.data;
    if (data is! List) return [];
    return data.map((e) => Mountain.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Mountain> getDetail(String id) async {
    final response = await api.get('/mountains/$id');
    return Mountain.fromJson(response.data as Map<String, dynamic>);
  }
}
