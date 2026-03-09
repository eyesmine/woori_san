import '../../core/api_client.dart';
import '../../models/stamp.dart';

class StampRemoteDataSource {
  final ApiClient api;

  StampRemoteDataSource(this.api);

  Future<List<Stamp>> getStamps() async {
    // TODO: 백엔드 연동 시 구현
    throw UnimplementedError('백엔드 미연동');
  }

  Future<void> updateStamp(Stamp stamp) async {
    // TODO: 백엔드 연동 시 구현
    throw UnimplementedError('백엔드 미연동');
  }
}
