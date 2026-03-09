import '../../core/api_client.dart';
import '../../models/hiking_plan.dart';

class PlanRemoteDataSource {
  final ApiClient api;

  PlanRemoteDataSource(this.api);

  Future<List<HikingPlan>> getPlans() async {
    // TODO: 백엔드 연동 시 구현
    throw UnimplementedError('백엔드 미연동');
  }

  Future<void> createPlan(HikingPlan plan) async {
    // TODO: 백엔드 연동 시 구현
    throw UnimplementedError('백엔드 미연동');
  }

  Future<void> deletePlan(String id) async {
    // TODO: 백엔드 연동 시 구현
    throw UnimplementedError('백엔드 미연동');
  }
}
