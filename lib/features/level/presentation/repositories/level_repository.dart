// ════════════════════════════════════════════════════════════════════════════
// FILE: lib/features/level/presentation/repositories/level_repository.dart
// ARVIND PARTY - LEVEL REPOSITORY
// ════════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';

class LevelRepository {
  final _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getLevelData() async {
    try {
      final response = await _api.get(ApiConstants.levels);
      return response as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<Map<String, dynamic>>> getXpBreakdown() async {
    try {
      final response = await _api.get(ApiConstants.gameLeaderboard);
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
