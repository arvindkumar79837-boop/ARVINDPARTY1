import 'package:get/get.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/api_exception.dart';

class SearchRepository {
  final _api = Get.find<ApiService>();

  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      final response = await _api.get(
        ApiConstants.userSearch,
        queryParameters: {'q': query},
      );
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        final results = data['data'] as List<dynamic>? ?? [];
        return results.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Search failed');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}