import 'package:dio/dio.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class FamilyRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  Future<List<Map<String, dynamic>>> fetchFamilies() async {
    try {
      final response = await _dio.get(ApiConstants.family);
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final families = data['data'] as List<dynamic>? ?? [];
        return families.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch families');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }
}