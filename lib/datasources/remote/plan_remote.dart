import '../../core/api_client.dart';
import '../../models/hiking_plan.dart';

class PlanRemoteDataSource {
  final ApiClient api;

  PlanRemoteDataSource(this.api);

  Future<List<HikingPlan>> getPlans() async {
    final response = await api.get('/plans');
    final data = response.data;
    if (data is! List) return [];
    return data.map((e) => HikingPlan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createPlan(HikingPlan plan) async {
    await api.post('/plans', data: plan.toJson());
  }

  Future<void> deletePlan(String id) async {
    await api.delete('/plans/$id');
  }
}
