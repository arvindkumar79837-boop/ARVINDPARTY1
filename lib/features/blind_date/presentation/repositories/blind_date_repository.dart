import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';

class BlindDateRepository {
  final Dio _dio;

  BlindDateRepository() : _dio = Get.find<ApiService>().dio;

  Future<Map<String, dynamic>> getProfile() async {
    final resp = await _dio.get('/blind-date/profile');
    return resp.data;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? genderPreference,
    int? ageRangeMin,
    int? ageRangeMax,
    List<String>? countryPreference,
    bool? isEnabled,
  }) async {
    final resp = await _dio.put('/blind-date/profile', data: {
      if (genderPreference != null) 'genderPreference': genderPreference,
      if (ageRangeMin != null) 'ageRangeMin': ageRangeMin,
      if (ageRangeMax != null) 'ageRangeMax': ageRangeMax,
      if (countryPreference != null) 'countryPreference': countryPreference,
      if (isEnabled != null) 'isEnabled': isEnabled,
    });
    return resp.data;
  }

  Future<Map<String, dynamic>> joinQueue() async {
    final resp = await _dio.post('/blind-date/join-queue');
    return resp.data;
  }

  Future<Map<String, dynamic>> leaveQueue() async {
    final resp = await _dio.post('/blind-date/leave-queue');
    return resp.data;
  }

  Future<Map<String, dynamic>> getSession(String sessionId) async {
    final resp = await _dio.get('/blind-date/session/$sessionId');
    return resp.data;
  }

  Future<Map<String, dynamic>> decide(String sessionId, String decision) async {
    final resp = await _dio.post('/blind-date/$sessionId/decide', data: {'decision': decision});
    return resp.data;
  }

  Future<Map<String, dynamic>> reportSession(String sessionId, String reason) async {
    final resp = await _dio.post('/blind-date/$sessionId/report', data: {'reason': reason});
    return resp.data;
  }
}
