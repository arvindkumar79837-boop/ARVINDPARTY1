import 'package:get/get.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/api_exception.dart';

class AgencyRepository {
  final _api = Get.find<ApiService>();

  AgencyRepository();

  Future<Map<String, dynamic>> fetchData() async {
    try {
      final response = await _api.get(ApiConstants.agency);
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> fetchMembers() async {
    try {
      final response = await _api.get(ApiConstants.agencyHosts);
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        final members = data['data'] as List<dynamic>? ?? [];
        return members.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch agency members');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> createAgency({
    required String name,
    String? description,
    String? logo,
  }) async {
    try {
      final body = <String, dynamic>{'name': name};
      if (description != null && description.isNotEmpty) body['description'] = description;
      if (logo != null && logo.isNotEmpty) body['logo'] = logo;

      final response = await _api.post(ApiConstants.agencyCreation, body: body);
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> fetchEarnings() async {
    try {
      final response = await _api.get(ApiConstants.agencyEarnings);
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>? ?? data;
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch agency earnings');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> startAttendanceSession({String? roomId}) async {
    try {
      final response = await _api.post('/agency/attendance/start', body: {'roomId': roomId ?? ''});
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> endAttendanceSession() async {
    try {
      final response = await _api.post('/agency/attendance/end');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getLiveAttendance() async {
    try {
      final response = await _api.get('/agency/attendance/live');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getMonthlyAttendance({int? month, int? year}) async {
    try {
      final response = await _api.get('/agency/attendance/monthly', queryParams: {'month': month, 'year': year});
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getSalaryHistory({int? month, int? year, String? hostId}) async {
    try {
      final response = await _api.get('/agency/salary/history', queryParams: {'month': month, 'year': year, 'hostId': hostId});
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getHostSalaryDetail(String hostId) async {
    try {
      final response = await _api.get('/agency/salary/detail/$hostId');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> sendHostRequest(String targetUid, {String? message}) async {
    try {
      final response = await _api.post('/agency/hosts/request', body: {'targetUid': targetUid, 'message': message ?? ''});
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getHostRequests() async {
    try {
      final response = await _api.get('/agency/hosts/requests');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> approveHostRequest(String requestId, {String? reviewNotes}) async {
    try {
      final response = await _api.post('/agency/hosts/approve/$requestId', body: {'reviewNotes': reviewNotes ?? ''});
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> rejectHostRequest(String requestId, {String? reviewNotes}) async {
    try {
      final response = await _api.post('/agency/hosts/reject/$requestId', body: {'reviewNotes': reviewNotes ?? ''});
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getRealtimeAnalytics() async {
    try {
      final response = await _api.get('/agency/reports/realtime');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getMonthlyReport({int? month, int? year}) async {
    try {
      final response = await _api.get('/agency/reports/monthly', queryParams: {'month': month, 'year': year});
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> awardBonus({
    required String hostId,
    required String reason,
    required double amount,
    String type = 'coins',
    String? vipTag,
    String? badgeId,
  }) async {
    try {
      final response = await _api.post('/agency/bonus/award', body: {
        'hostId': hostId,
        'reason': reason,
        'type': type,
        'amount': amount,
        'vipTag': vipTag ?? '',
        'badgeId': badgeId ?? '',
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> applyPenalty({
    required String hostId,
    required String reason,
    required double amount,
    String type = 'coins',
    bool isPercentage = false,
  }) async {
    try {
      final response = await _api.post('/agency/penalty/apply', body: {
        'hostId': hostId,
        'reason': reason,
        'type': type,
        'amount': amount,
        'isPercentage': isPercentage,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    String currency = 'coins',
    String settlementMethod = 'bank_transfer',
    Map<String, dynamic>? accountDetails,
  }) async {
    try {
      final response = await _api.post('/agency/withdrawal/request', body: {
        'amount': amount,
        'currency': currency,
        'settlementMethod': settlementMethod,
        'accountDetails': accountDetails ?? {},
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getWithdrawalHistory() async {
    try {
      final response = await _api.get('/agency/withdrawal/history');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> addAgent(String uid, {double commissionRate = 5.0}) async {
    try {
      final response = await _api.post('/agency/agents/add', body: {'uid': uid, 'commissionRate': commissionRate});
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getAgents() async {
    try {
      final response = await _api.get('/agency/agents');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>?> getHostAgencyDashboard() async {
    try {
      final response = await _api.get('/wallet/agency/host-dashboard');
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>?> getOwnerAgencyDashboard() async {
    try {
      final response = await _api.get('/wallet/agency/owner-dashboard');
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getAgencyMonthlyHistory({int months = 6}) async {
    try {
      final response = await _api.get('/wallet/agency/monthly-history', queryParams: {'months': months});
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']['history'] ?? []);
      }
      return [];
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
