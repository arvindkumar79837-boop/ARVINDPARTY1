import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class ShopRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  String? _getToken() {
    try {
      return Get.find<AuthSessionManager>().token.value;
    } catch (_) {
      return null;
    }
  }

  Options _authOptions() => Options(headers: {
        if (_getToken() != null) 'Authorization': 'Bearer ${_getToken()}',
      });

  /// Fetch all shop items (frames, mounts, bubbles)
  /// GET /api/shop/items
  Future<List<Map<String, dynamic>>> fetchItems() async {
    try {
      final response = await _dio.get(
        ApiConstants.shopItems,
        options: _authOptions(),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['items'] != null) {
        final items = data['items'] as List<dynamic>;
        return items.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch shop items');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Purchase an item from the shop
  /// POST /api/shop/purchase
  Future<Map<String, dynamic>> purchaseItem(String itemId) async {
    try {
      final response = await _dio.post(
        ApiConstants.shopPurchase,
        data: {'itemId': itemId},
        options: _authOptions(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }
}
