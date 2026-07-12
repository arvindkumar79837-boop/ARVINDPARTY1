import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';

class EventsRepository {
  final _api = Get.find<ApiService>();

  AuthSessionManager get _session {
    return Get.find<AuthSessionManager>();
  }

  String _getAuthHeader() {
    final token = _session.token.value;
    return 'Bearer $token';
  }

  Future<List<Map<String, dynamic>>> fetchEvents({
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.dio.get(
        '/events/list',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null && type.isNotEmpty) 'type': type,
          if (status != null && status.isNotEmpty) 'status': status,
        },
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch events');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> fetchActiveEvents() async {
    try {
      final response = await _api.dio.get(
        '/events/list',
        queryParameters: {'status': 'active'},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> fetchTournaments() async {
    try {
      final response = await _api.dio.get(
        '/tournaments/list',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> fetchChampionships() async {
    try {
      final response = await _api.dio.get(
        '/tournaments/championship/list',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> fetchTreasureHunts() async {
    try {
      final response = await _api.dio.get(
        '/treasure-hunts/list',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<void> registerForTournament(String tournamentId) async {
    try {
      final response = await _api.dio.post(
        '/tournaments/$tournamentId/register',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw ApiException(message: data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<void> qualifyForChampionship(String championshipId) async {
    try {
      final response = await _api.dio.post(
        '/tournaments/championship/$championshipId/qualify',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw ApiException(message: data['message'] ?? 'Qualification failed');
      }
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> collectTreasureKey(String huntId) async {
    try {
      final response = await _api.dio.post(
        '/treasure-hunts/$huntId/collect-key',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to collect key');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _api.dio.post(
        '/events/admin/create',
        data: eventData,
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to create event');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> fetchActiveLuckyDraws() async {
    try {
      final response = await _api.dio.get(
        '/lucky-draws/active',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getLuckyDrawById(String drawId) async {
    try {
      final response = await _api.dio.get(
        '/lucky-draws/$drawId',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return Map<String, dynamic>.from(data['data'] ?? {});
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> spinWheel(String drawId) async {
    try {
      final response = await _api.dio.post(
        '/lucky-draws/$drawId/spin',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Spin failed');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> fetchActiveDailyTasks() async {
    try {
      final response = await _api.dio.get(
        '/daily-tasks/active',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> updateTaskProgress(String taskId, int increment) async {
    try {
      final response = await _api.dio.put(
        '/daily-tasks/$taskId/progress',
        data: {'progressIncrement': increment},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return Map<String, dynamic>.from(data['data'] ?? {});
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> claimTaskReward(String taskId) async {
    try {
      final response = await _api.dio.post(
        '/daily-tasks/$taskId/claim',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to claim reward');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> generateInviteLink(int commissionPercent) async {
    try {
      final response = await _api.dio.post(
        '/invites/generate',
        data: {'commission_percent': commissionPercent},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to generate link');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getInviteStats() async {
    try {
      final response = await _api.dio.get(
        '/invites/my-stats',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to get stats');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getLoginStreak() async {
    try {
      final response = await _api.dio.get(
        '/login-streak/my-streak',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to get streak');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> claimDailyLogin() async {
    try {
      final response = await _api.dio.post(
        '/login-streak/claim-daily',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to claim login');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> fetchMasterActiveEvents() async {
    try {
      final response = await _api.dio.get(
        '/events/active',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getEventDetails(String eventId) async {
    try {
      final response = await _api.dio.get(
        '/events/$eventId',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return Map<String, dynamic>.from(data['data'] ?? {});
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> joinEvent(String eventId) async {
    try {
      final response = await _api.dio.post(
        '/events/$eventId/join',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to join event');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> leaveEvent(String eventId) async {
    try {
      final response = await _api.dio.post(
        '/events/$eventId/leave',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to leave event');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> claimEventReward(String eventId) async {
    try {
      final response = await _api.dio.post(
        '/events/$eventId/claim',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to claim reward');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getEventsDashboard() async {
    try {
      final response = await _api.dio.get(
        '/events/dashboard',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return Map<String, dynamic>.from(data['data'] ?? {});
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getEventPrizePool(String eventId) async {
    try {
      final response = await _api.dio.get(
        '/events/$eventId/prize-pool',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return Map<String, dynamic>.from(data['data'] ?? {});
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getTournamentStandings(String eventId) async {
    try {
      final response = await _api.dio.get(
        '/events/$eventId/tournament/standings',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getWelcomeWeekTasks() async {
    try {
      final response = await _api.dio.get(
        '/events/admin/welcome-week/tasks',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getFestivalGifts(String? festivalType) async {
    try {
      final response = await _api.dio.get(
        '/events/admin/festival/gifts',
        queryParameters: festivalType != null ? {'festival_type': festivalType} : null,
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getAnniversaryRewards(int? year) async {
    try {
      final response = await _api.dio.get(
        '/events/admin/anniversary/rewards',
        queryParameters: year != null ? {'year_anniversary': year} : null,
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}