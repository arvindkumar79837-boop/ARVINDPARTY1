import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';

class EventsRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  EventsRepository();

  AuthSessionManager get _session {
    return Get.find<AuthSessionManager>();
  }

  String _getAuthHeader() {
    final token = _session.token;
    return 'Bearer $token';
  }

  Future<List<Map<String, dynamic>>> fetchEvents({
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/events/list',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null && type.isNotEmpty) 'type': type,
          if (status != null && status.isNotEmpty) 'status': status,
        },
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final events = data['data'] as List<dynamic>? ?? [];
        return events
            .map((event) => Map<String, dynamic>.from(event as Map))
            .toList();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch events');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<List<Map<String, dynamic>>> fetchActiveEvents() async {
    try {
      final response = await _dio.get(
        '/events/list',
        queryParameters: {'status': 'active'},
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final events = data['data'] as List<dynamic>? ?? [];
        return events
            .map((event) => Map<String, dynamic>.from(event as Map))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<List<Map<String, dynamic>>> fetchTournaments() async {
    try {
      final response = await _dio.get(
        '/tournaments/list',
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final tournaments = data['data'] as List<dynamic>? ?? [];
        return tournaments
            .map((t) => Map<String, dynamic>.from(t as Map))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<List<Map<String, dynamic>>> fetchChampionships() async {
    try {
      final response = await _dio.get(
        '/tournaments/championship/list',
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final championships = data['data'] as List<dynamic>? ?? [];
        return championships
            .map((c) => Map<String, dynamic>.from(c as Map))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<List<Map<String, dynamic>>> fetchTreasureHunts() async {
    try {
      final response = await _dio.get(
        '/treasure-hunts/list',
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final hunts = data['data'] as List<dynamic>? ?? [];
        return hunts
            .map((h) => Map<String, dynamic>.from(h as Map))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<void> registerForTournament(String tournamentId) async {
    try {
      final response = await _dio.post(
        '/tournaments/$tournamentId/register',
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw ApiException(message: data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<void> qualifyForChampionship(String championshipId) async {
    try {
      final response = await _dio.post(
        '/tournaments/championship/$championshipId/qualify',
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw ApiException(message: data['message'] ?? 'Qualification failed');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> collectTreasureKey(String huntId) async {
    try {
      final response = await _dio.post(
        '/treasure-hunts/$huntId/collect-key',
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to collect key');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? coverImage,
    int maxParticipants = 0,
    bool isFeatured = false,
    String status = 'upcoming',
    int rewardCoins = 0,
    int rewardDiamonds = 0,
    int rewardXp = 0,
  }) async {
    try {
      final response = await _dio.post(
        '/events/admin/create',
        data: {
          'event_name': title,
          'event_type': type.toUpperCase(),
          'description': description,
          'start_time': startDate.toIso8601String(),
          'end_time': endDate.toIso8601String(),
          'reward_details': {
            'coins': rewardCoins,
            'diamonds': rewardDiamonds,
            'xp': rewardXp,
          },
          'max_participants': maxParticipants,
        },
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(
          (data['data'] ?? data['event'] ?? data) as Map,
        );
      }

      throw ApiException(message: data['message'] ?? 'Failed to create event');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // NEW: LUCKY DRAW METHODS
  // ═════════════════════════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> fetchActiveLuckyDraws() async {
    try {
      final response = await _dio.get(
        '/lucky-draws/active',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List<dynamic>?)
                ?.map((d) => Map<String, dynamic>.from(d as Map))
                .toList() ??
            [];
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getLuckyDrawById(String drawId) async {
    try {
      final response = await _dio.get(
        '/lucky-draws/$drawId',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch draw');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> spinWheel(String drawId) async {
    try {
      final response = await _dio.post(
        '/lucky-draws/$drawId/spin',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Spin failed');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // NEW: DAILY TASKS METHODS
  // ═════════════════════════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> fetchActiveDailyTasks() async {
    try {
      final response = await _dio.get(
        '/daily-tasks/active',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List<dynamic>?)
                ?.map((t) => Map<String, dynamic>.from(t as Map))
                .toList() ??
            [];
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> updateTaskProgress(String taskId, {int increment = 1}) async {
    try {
      final response = await _dio.put(
        '/daily-tasks/$taskId/progress',
        data: {'progressIncrement': increment},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to update progress');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> claimTaskReward(String taskId) async {
    try {
      final response = await _dio.post(
        '/daily-tasks/$taskId/claim',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to claim reward');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // NEW: INVITE/REFERRAL METHODS
  // ═════════════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> generateInviteLink({int commissionPercent = 5}) async {
    try {
      final response = await _dio.post(
        '/invites/generate',
        data: {'commission_percent': commissionPercent},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to generate link');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getInviteStats() async {
    try {
      final response = await _dio.get(
        '/invites/my-stats',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to get stats');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // NEW: LOGIN STREAK METHODS
  // ═════════════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> getLoginStreak() async {
    try {
      final response = await _dio.get(
        '/login-streak/my-streak',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to get streak');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> claimDailyLogin() async {
    try {
      final response = await _dio.post(
        '/login-streak/claim-daily',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to claim login');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // NEW: MASTER EVENT ENGINE METHODS
  // ═════════════════════════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> fetchMasterActiveEvents() async {
    try {
      final response = await _dio.get(
        '/events/active',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [];
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getEventDetails(String eventId) async {
    try {
      final response = await _dio.get(
        '/events/$eventId',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch event');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> joinEvent(String eventId) async {
    try {
      final response = await _dio.post(
        '/events/$eventId/join',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to join event');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> leaveEvent(String eventId) async {
    try {
      final response = await _dio.post(
        '/events/$eventId/leave',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to leave event');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> claimEventReward(String eventId) async {
    try {
      final response = await _dio.post(
        '/events/$eventId/claim',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to claim reward');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> updateEventProgress(
    String eventId,
    String taskId,
    int progressValue, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        '/events/$eventId/progress',
        data: {
          'taskId': taskId,
          'progress_value': progressValue,
          if (metadata != null) 'metadata': metadata,
        },
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to update progress');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<List<Map<String, dynamic>>> getUserEventHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/events/user/history',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final history = data['data'] as List<dynamic>? ?? [];
        return history.map((h) => Map<String, dynamic>.from(h as Map)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getEventsDashboard() async {
    try {
      final response = await _dio.get(
        '/events/dashboard',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch dashboard');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<Map<String, dynamic>> getEventPrizePool(String eventId) async {
    try {
      final response = await _dio.get(
        '/events/$eventId/prize-pool',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch prize pool');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<List<Map<String, dynamic>>> getTournamentStandings(String eventId) async {
    try {
      final response = await _dio.get(
        '/events/$eventId/tournament/standings',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final standings = data['data'] as List<dynamic>? ?? [];
        return standings.map((s) => Map<String, dynamic>.from(s as Map)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<List<Map<String, dynamic>>> getWelcomeWeekTasks() async {
    try {
      final response = await _dio.get(
        '/events/admin/welcome-week/tasks',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List<dynamic>?)
                ?.map((t) => Map<String, dynamic>.from(t as Map))
                .toList() ??
            [];
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<List<Map<String, dynamic>>> getFestivalGifts({String? festivalType}) async {
    try {
      final response = await _dio.get(
        '/events/admin/festival/gifts',
        queryParameters: {
          if (festivalType != null && festivalType.isNotEmpty) 'festival_type': festivalType,
        },
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List<dynamic>?)
                ?.map((g) => Map<String, dynamic>.from(g as Map))
                .toList() ??
            [];
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  Future<List<Map<String, dynamic>>> getAnniversaryRewards({int? year}) async {
    try {
      final response = await _dio.get(
        '/events/admin/anniversary/rewards',
        queryParameters: year != null ? {'year_anniversary': year} : null,
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List<dynamic>?)
                ?.map((r) => Map<String, dynamic>.from(r as Map))
                .toList() ??
            [];
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }
}
