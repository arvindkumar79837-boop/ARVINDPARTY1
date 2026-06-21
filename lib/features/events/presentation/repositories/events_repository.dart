import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class EventsRepository {
  final Dio _dio =  Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));
  AuthSessionManager get _session => Get.find<AuthSessionManager>();

  String _getAuthHeader() {
    final token =  _session.token ?? '';
    return 'Bearer $token';
  }

  Future<List<Map<String, dynamic>>> fetchEvents({
    String? type,
    String? status,
    int page =  1,
    int limit =  20,
  }) async {
    try {
      final response =  await _dio.get(
        ApiConstants.eventListing,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null && type.isNotEmpty) 'type': type,
          if (status != null && status.isNotEmpty) 'status': status,
        },
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );
      final data =  response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final events =  data['data'] as List<dynamic>? ?? [];
        return events
            .map((event) => Map<String, dynamic>.from(event as Map))
            .toList();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch events');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? coverImage,
    int maxParticipants =  0,
    bool isFeatured =  false,
    String status =  'upcoming',
    int rewardCoins =  0,
    int rewardDiamonds =  0,
    int rewardXp =  0,
  }) async {
    try {
      final response =  await _dio.post(
        ApiConstants.eventCreation,
        data: {
          'title': title,
          'description': description,
          'type': type,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'coverImage': coverImage ?? '',
          'maxParticipants': maxParticipants,
          'isFeatured': isFeatured,
          'status': status,
          'rewards': {
            'coins': rewardCoins,
            'diamonds': rewardDiamonds,
            'xp': rewardXp,
          },
        },
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );

      final data =  response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(
          (data['data'] ?? data['event'] ?? data) as Map,
        );
      }

      throw ApiException(message: data['message'] ?? 'Failed to create event');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }
}
