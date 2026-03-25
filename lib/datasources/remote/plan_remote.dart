import '../../core/api_client.dart';
import '../../models/hiking_plan.dart';

class PlanRemoteDataSource {
  final ApiClient api;

  PlanRemoteDataSource(this.api);

  /// GET /api/plans/ — DRF pagination 대응
  Future<List<HikingPlan>> getPlans() async {
    final response = await api.get('/plans/');
    final data = response.data;
    final list = data is Map ? data['results'] as List? ?? [] : data is List ? data : [];
    return list.map((e) => HikingPlan.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /api/plans/
  Future<HikingPlan> createPlan(HikingPlan plan) async {
    final response = await api.post('/plans/', data: plan.toJson());
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final created = HikingPlan.fromJson(data);
      return created.copyWith(
        mountain: created.mountain.isNotEmpty ? created.mountain : plan.mountain,
        mountainId: created.mountainId ?? plan.mountainId,
        emoji: created.emoji.isNotEmpty ? created.emoji : plan.emoji,
        memo: created.memo ?? plan.memo,
      );
    }
    return plan;
  }

  /// GET /api/plans/{id}/
  Future<HikingPlan> getPlan(String id) async {
    final response = await api.get('/plans/$id/');
    return HikingPlan.fromJson(response.data as Map<String, dynamic>);
  }

  /// PUT /api/plans/{id}/
  Future<void> updatePlan(String id, Map<String, dynamic> data) async {
    await api.put('/plans/$id/', data: data);
  }

  /// DELETE /api/plans/{id}/
  Future<void> deletePlan(String id) async {
    await api.delete('/plans/$id/');
  }

  /// POST /api/plans/{id}/invite/
  Future<void> invitePartner(String id) async {
    await api.post('/plans/$id/invite/');
  }

  /// PATCH /api/plans/{id}/status/
  Future<void> updateStatus(String id, String status) async {
    await api.patch('/plans/$id/status/', data: {'status': status});
  }

  /// GET /api/plans/{id}/checklist/ — DRF pagination 대응
  Future<List<Map<String, dynamic>>> getChecklist(String id) async {
    final response = await api.get('/plans/$id/checklist/');
    final data = response.data;
    final list = data is Map ? data['results'] as List? ?? [] : data is List ? data : [];
    return list.cast<Map<String, dynamic>>();
  }

  /// POST /api/plans/{id}/checklist/
  Future<void> addChecklistItem(String id, Map<String, dynamic> item) async {
    await api.post('/plans/$id/checklist/', data: item);
  }

  /// PATCH /api/plans/{id}/checklist/{itemId}/
  Future<void> toggleChecklistItem(String planId, String itemId) async {
    await api.patch('/plans/$planId/checklist/$itemId/');
  }
}
