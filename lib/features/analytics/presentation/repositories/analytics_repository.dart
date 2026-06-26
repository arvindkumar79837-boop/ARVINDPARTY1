import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class AnalyticsRepository {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getRevenueSummary() async {
    final response = await _api.get('/analytics/revenue/summary');
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception(response['message'] ?? 'Failed to load revenue summary');
  }

  Future<Map<String, dynamic>> getRechargeAnalytics({int page = 1, int limit = 10, String? userId, String? coinSellerId, String? startDate, String? endDate}) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (userId != null) query['userId'] = userId;
    if (coinSellerId != null) query['coinSellerId'] = coinSellerId;
    if (startDate != null) query['startDate'] = startDate;
    if (endDate != null) query['endDate'] = endDate;
    final response = await _api.get('/analytics/revenue/recharges', query: query);
    return response;
  }

  Future<Map<String, dynamic>> getWithdrawalAnalytics({int page = 1, int limit = 10, String? status, String? agencyId}) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) query['status'] = status;
    if (agencyId != null) query['agencyId'] = agencyId;
    final response = await _api.get('/analytics/revenue/withdrawals', query: query);
    return response;
  }

  Future<Map<String, dynamic>> getUserAnalytics() async {
    final response = await _api.get('/analytics/engagement/users');
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to load user analytics');
  }

  Future<Map<String, dynamic>> getLiveAnalytics() async {
    final response = await _api.get('/analytics/engagement/live');
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to load live analytics');
  }

  Future<Map<String, dynamic>> getGiftAnalytics() async {
    final response = await _api.get('/analytics/engagement/gifts');
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to load gift analytics');
  }

  Future<List<dynamic>> getAgencyAnalytics({int limit = 20}) async {
    final response = await _api.get('/analytics/performance/agencies', query: {'limit': limit});
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }
    throw Exception('Failed to load agency analytics');
  }

  Future<List<dynamic>> getFamilyAnalytics({int limit = 20}) async {
    final response = await _api.get('/analytics/performance/families', query: {'limit': limit});
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }
    throw Exception('Failed to load family analytics');
  }

  Future<Map<String, dynamic>> getLiveChartData() async {
    final response = await _api.get('/analytics/charts/live');
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to load chart data');
  }

  Future<List<dynamic>> getHeatMapData({String? country, String? date}) async {
    final query = <String, dynamic>{};
    if (country != null) query['country'] = country;
    if (date != null) query['date'] = date;
    final response = await _api.get('/analytics/charts/heatmap', query: query);
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }
    throw Exception('Failed to load heat map data');
  }
}