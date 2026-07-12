// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/blind_date/presentation/repositories/blind_date_repository.dart
// ARVIND PARTY - BLIND DATE REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';

class BlindDateRepository {
  final _api = Get.find<ApiService>();

  String? _getToken() {
    try {
      return Get.find<AuthSessionManager>().token.value;
    } catch (e) { debugPrint('Error: $e'); return null; }
  }

  Options _authOptions() => Options(headers: {
        if (_getToken() != null) 'Authorization': 'Bearer ${_getToken()}',
      });

  /// Start searching for a blind date match
  /// POST /api/matchmaking/search
  Future<Map<String, dynamic>> searchMatch() async {
    try {
      final response = await _api.dio.post(
        ApiConstants.blindMatch,
        options: _authOptions(),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Stop searching for a match
  /// POST /api/matchmaking/stop
  Future<void> stopSearch() async {
    try {
      await _api.dio.post(
        ApiConstants.blindMatchStop,
        options: _authOptions(),
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}