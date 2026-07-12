import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';

class RankingRepository {
  final _api = Get.find<ApiService>();

  RankingRepository();

  AuthSessionManager get _session {
    return Get.find<AuthSessionManager>();
  }

  String _getAuthHeader() {
    final token = _session.token;
    return 'Bearer $token';
  }

  Future<List<Map<String, dynamic>>> fetchRankings(String type) async {
    try {
      final endpoint =  _endpointForType(type);
      final response =  await _api.get(
        endpoint,
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );

      return _parseRankings(response);
    } catch (e) {
      throw ApiException(message: e.toString());
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
        case 'families':
          return '${ApiConstants.rankings}/families';
        case 'agencies':
          return '${ApiConstants.rankings}/agencies';
        case 'rooms':
          return '${ApiConstants.rankings}/rooms';
        case 'pk-battles':
          return '${ApiConstants.rankings}/pk-battles';
        case 'rich-list':
          return '${ApiConstants.rankings}/rich-list';
        case 'popular-list':
          return '${ApiConstants.rankings}/popular-list';
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
