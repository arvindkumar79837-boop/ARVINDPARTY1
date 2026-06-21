import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class AgencyRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  // FIXED: Space hata kar arrow operator '=>' ko sahi kiya
  AuthSessionManager get _session => Get.find<AuthSessionManager>();

  String _getAuthHeader() {
    final token = _session.token ?? '';
    return 'Bearer $token';
  }

  /// Fetch agency info
  /// Matches backend: GET /api/agency
  Future<Map<String, dynamic>> fetchData() async {
    try {
      final response = await _dio.get(
        ApiConstants.agency,
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Fetch agency members/hosts
  /// Matches backend: GET /api/agency/hosts
  Future<List<Map<String, dynamic>>> fetchMembers() async {
    try {
      final response = await _dio.get(
        ApiConstants.agencyHosts,
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final members = data['data'] as List<dynamic>? ?? [];
        // Safer conversion for Map elements
        return members.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch agency members');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Create a new agency
  /// Matches backend: POST /api/agency/create
  Future<Map<String, dynamic>> createAgency({
    required String name,
    String? description,
    String? logo,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
      };
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }
      if (logo != null && logo.isNotEmpty) {
        body['logo'] = logo;
      }

      final response = await _dio.post(
        ApiConstants.agencyCreation,
        data: body,
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Fetch agency earnings
  /// Matches backend: GET /api/agency/earnings
  Future<Map<String, dynamic>> fetchEarnings() async {
    try {
      final response = await _dio.get(
        ApiConstants.agencyEarnings,
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
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
}