import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class AnalyticsRepository {
  final _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getRevenueSummary() async {
    try {
      final response = await _api.get('/analytics/revenue/summary');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getUserAnalytics() async {
    try {
      final response = await _api.get('/analytics/users');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getLiveAnalytics() async {
    try {
      final response = await _api.get('/analytics/live');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getGiftAnalytics() async {
    try {
      final response = await _api.get('/analytics/gifts');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getAgencyRankings() async {
    try {
      final response = await _api.get('/analytics/agencies/rankings');
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getFamilyRankings() async {
    try {
      final response = await _api.get('/analytics/families/rankings');
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getHourlyRevenue() async {
    try {
      final response = await _api.get('/analytics/revenue/hourly');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getActivityHeatMap() async {
    try {
      final response = await _api.get('/analytics/activity/heatmap');
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}