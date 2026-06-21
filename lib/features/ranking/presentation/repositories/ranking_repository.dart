import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class RankingRepository {
  final Dio _dio =  Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  AuthSessionManager get _session => Get.find<AuthSessionManager>();

  String _getAuthHeader() {
    final token =  _session.token ?? '';
    return 'Bearer $token';
  }

  Future<List<Map<String, dynamic>>> fetchRankings(String type) async {
    try {
      final endpoint =  _endpointForType(type);
      final response =  await _dio.get(
        endpoint,
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );

      return _parseRankings(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  String _endpointForType(String type) {
      switch (type) {
        case 'wealth':
          return ApiConstants.wealthRanking;
        case 'charm':
          return ApiConstants.charmRanking;
        case 'gift':
          return ApiConstants.giftRanking;
        default:
          return ApiConstants.wealthRanking;
      }
  }

  List<Map<String, dynamic>> _parseRankings(dynamic responseData) {
    if (responseData is List) {
      return responseData.map((entry) => Map<String, dynamic>.from(entry as Map)).toList();
    }

    if (responseData is Map<String, dynamic>) {
      if (responseData['success'] == false) {
        throw ApiException(
          message: responseData['message']?.toString() ?? 'Failed to fetch rankings',
        );
      }

      final rankings =  responseData['rankings'] ?? responseData['data'] ?? responseData['results'];
      if (rankings is List) {
        return rankings
            .map((entry) => Map<String, dynamic>.from(entry as Map))
            .toList();
      }
    }

    throw ApiException(message: 'Invalid ranking response');
  }
}
