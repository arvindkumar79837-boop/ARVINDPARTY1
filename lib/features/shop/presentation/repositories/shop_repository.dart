import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';

class ShopRepository {
  final _api = Get.find<ApiService>();

  String? _getToken() {
    try {
      return Get.find<AuthSessionManager>().token.value;
    } catch (_) { return null; }
  }

  Options _authOptions() => Options(headers: {
        if (_getToken() != null) 'Authorization': 'Bearer ${_getToken()}',
      });

  /// Fetch all shop items (frames, mounts, bubbles)
  /// GET /api/shop/items
  Future<List<Map<String, dynamic>>> fetchItems() async {
    try {
      final response = await _api.get(
        ApiConstants.shopItems,
        options: _authOptions(),
      );
      final data = response as Map<String, dynamic>;
      if (data['items'] != null) {
        final items = data['items'] as List<dynamic>;
        return items.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch shop items');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Purchase an item from the shop
  /// POST /api/shop/purchase
  Future<Map<String, dynamic>> purchaseItem(String itemId) async {
    try {
      final response = await _api.post(
        ApiConstants.shopPurchase,
        data: {'itemId': itemId},
        options: _authOptions(),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
