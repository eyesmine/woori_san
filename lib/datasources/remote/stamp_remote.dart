import '../../core/api_client.dart';
import '../../models/stamp.dart';

class StampRemoteDataSource {
  final ApiClient api;

  StampRemoteDataSource(this.api);

  Future<List<Stamp>> getStamps() async {
    final response = await api.get('/stamps');
    final data = response.data;
    if (data is! List) return [];
    return data.map((e) => Stamp.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateStamp(Stamp stamp) async {
    await api.put('/stamps/${stamp.name}', data: stamp.toJson());
  }
}
