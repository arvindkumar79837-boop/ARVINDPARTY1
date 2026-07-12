// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/pk_battle/presentation/repositories/pk_battle_repository.dart
// ARVIND PARTY - PK BATTLE REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';

class PkBattleRepository {
  final _api = Get.find<ApiService>();

  String? _getToken() {
    try {
      return Get.find<AuthSessionManager>().token.value;
    } catch (e) { debugPrint('Error: $e'); return null; }
  }

  Options _authOptions() => Options(headers: {
        if (_getToken() != null) 'Authorization': 'Bearer ${_getToken()}',
      });

  /// Request a PK battle with an opponent
  /// POST /api/pk-battles/request
  Future<Map<String, dynamic>> requestBattle({required String opponentId, required String roomId, int? durationMinutes}) async {
    try {
      final response = await _api.post(
        ApiConstants.pkRequest,
        data: {
          'opponentId': opponentId,
          'roomId': roomId,
          'durationMinutes': durationMinutes ?? 5,
        },
        options: _authOptions(),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Accept a pending PK battle request
  /// POST /api/pk-battles/accept
  Future<Map<String, dynamic>> acceptBattle(String battleId) async {
    try {
      final response = await _api.post(
        ApiConstants.pkAccept,
        data: {'battleId': battleId},
        options: _authOptions(),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// End a live PK battle (typically called by host/admin)
  /// POST /api/pk-battles/end
  Future<Map<String, dynamic>> endBattle(String battleId) async {
    try {
      final response = await _api.post(
        ApiConstants.pkEnd,
        data: {'battleId': battleId},
        options: _authOptions(),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
