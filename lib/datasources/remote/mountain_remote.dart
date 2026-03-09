import '../../core/api_client.dart';
import '../../models/mountain.dart';

class MountainRemoteDataSource {
  final ApiClient api;

  MountainRemoteDataSource(this.api);

  Future<List<Mountain>> getRecommended() async {
    // TODO: 백엔드 연동 시 구현
    // final response = await _api.get('/mountains/recommended');
    // return (response.data as List).map((e) => Mountain.fromJson(e)).toList();
    throw UnimplementedError('백엔드 미연동');
  }

  Future<Mountain> getDetail(String id) async {
    // TODO: 백엔드 연동 시 구현
    throw UnimplementedError('백엔드 미연동');
  }
}
