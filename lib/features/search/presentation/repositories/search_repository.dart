import 'package:dio/dio.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class SearchRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      final response = await _dio.get(
        ApiConstants.userSearch,
        queryParameters: {'q': query},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final results = data['data'] as List<dynamic>? ?? [];
        return results.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Search failed');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }
}