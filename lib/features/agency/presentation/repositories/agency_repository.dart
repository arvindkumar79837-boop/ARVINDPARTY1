import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class AgencyRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  AgencyRepository();

  AuthSessionManager get _session {
    return Get.find<AuthSessionManager>();
  }

  String _getAuthHeader() {
    final token = _session.token;
    return 'Bearer $token';
  }

  Future<Map<String, dynamic>> fetchData() async {
    try {
      final response = await _dio.get(
        ApiConstants.agency,
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<List<Map<String, dynamic>>> fetchMembers() async {
    try {
      final response = await _dio.get(
        ApiConstants.agencyHosts,
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final members = data['data'] as List<dynamic>? ?? [];
        return members.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch agency members');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
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

      final response = await _dio.post(
        ApiConstants.agencyCreation,
        data: body,
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> fetchEarnings() async {
    try {
      final response = await _dio.get(
        ApiConstants.agencyEarnings,
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>? ?? data;
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch agency earnings');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> startAttendanceSession({String? roomId}) async {
    try {
      final response = await _dio.post(
        '/api/agency/attendance/start',
        data: {'roomId': roomId ?? ''},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> endAttendanceSession() async {
    try {
      final response = await _dio.post(
        '/api/agency/attendance/end',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getLiveAttendance() async {
    try {
      final response = await _dio.get(
        '/api/agency/attendance/live',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getMonthlyAttendance({int? month, int? year}) async {
    try {
      final response = await _dio.get(
        '/api/agency/attendance/monthly',
        queryParameters: {'month': month, 'year': year},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getSalaryHistory({int? month, int? year, String? hostId}) async {
    try {
      final response = await _dio.get(
        '/api/agency/salary/history',
        queryParameters: {'month': month, 'year': year, 'hostId': hostId},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getHostSalaryDetail(String hostId) async {
    try {
      final response = await _dio.get(
        '/api/agency/salary/detail/$hostId',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> sendHostRequest(String targetUid, {String? message}) async {
    try {
      final response = await _dio.post(
        '/api/agency/hosts/request',
        data: {'targetUid': targetUid, 'message': message ?? ''},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getHostRequests() async {
    try {
      final response = await _dio.get(
        '/api/agency/hosts/requests',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> approveHostRequest(String requestId, {String? reviewNotes}) async {
    try {
      final response = await _dio.post(
        '/api/agency/hosts/approve/$requestId',
        data: {'reviewNotes': reviewNotes ?? ''},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> rejectHostRequest(String requestId, {String? reviewNotes}) async {
    try {
      final response = await _dio.post(
        '/api/agency/hosts/reject/$requestId',
        data: {'reviewNotes': reviewNotes ?? ''},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getRealtimeAnalytics() async {
    try {
      final response = await _dio.get(
        '/api/agency/reports/realtime',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getMonthlyReport({int? month, int? year}) async {
    try {
      final response = await _dio.get(
        '/api/agency/reports/monthly',
        queryParameters: {'month': month, 'year': year},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
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
      final response = await _dio.post(
        '/api/agency/bonus/award',
        data: {
          'hostId': hostId,
          'reason': reason,
          'type': type,
          'amount': amount,
          'vipTag': vipTag ?? '',
          'badgeId': badgeId ?? '',
        },
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
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
      final response = await _dio.post(
        '/api/agency/penalty/apply',
        data: {
          'hostId': hostId,
          'reason': reason,
          'type': type,
          'amount': amount,
          'isPercentage': isPercentage,
        },
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    String currency = 'coins',
    String settlementMethod = 'bank_transfer',
    Map<String, dynamic>? accountDetails,
  }) async {
    try {
      final response = await _dio.post(
        '/api/agency/withdrawal/request',
        data: {
          'amount': amount,
          'currency': currency,
          'settlementMethod': settlementMethod,
          'accountDetails': accountDetails ?? {},
        },
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getWithdrawalHistory() async {
    try {
      final response = await _dio.get(
        '/api/agency/withdrawal/history',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> addAgent(String uid, {double commissionRate = 5.0}) async {
    try {
      final response = await _dio.post(
        '/api/agency/agents/add',
        data: {'uid': uid, 'commissionRate': commissionRate},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getAgents() async {
    try {
      final response = await _dio.get(
        '/api/agency/agents',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>?> getHostAgencyDashboard() async {
    try {
      final response = await _dio.get(
        '/api/wallet/agency/host-dashboard',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>?> getOwnerAgencyDashboard() async {
    try {
      final response = await _dio.get(
        '/api/wallet/agency/owner-dashboard',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<List<Map<String, dynamic>>> getAgencyMonthlyHistory({int months = 6}) async {
    try {
      final response = await _dio.get(
        '/api/wallet/agency/monthly-history',
        queryParameters: {'months': months},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']['history'] ?? []);
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }
}
