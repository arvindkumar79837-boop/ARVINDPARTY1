// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/home/presentation/repositories/home_repository.dart
// ARVIND PARTY - HOME REPOSITORY (Banners, Categories, Rooms by type)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
import '../../models/home_model.dart';

class HomeRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<BannerModel>> getBanners() async {
    final response = await _apiService.get('/home/banners');
    if (response is Map && response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiService.get('/home/categories');
    if (response is Map && response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<List<HomeRoomItem>> getRoomsByType(String type) async {
    final response = await _apiService.get('/rooms/list', query: {'type': type});
    if (response is Map && response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((e) => HomeRoomItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }
}
