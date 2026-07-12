import 'package:get/get.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/utils/api_exception.dart';

class FamilyRepository {
  final _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getMyFamily() async {
    try {
      final response = await _api.dio.get('/families/mine');
      final data = response as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> createFamily({
    required String familyName,
    required String familyBadge,
    String? slogan,
    String? familyIntro,
  }) async {
    try {
      final response = await _api.dio.post(
        '/families/create',
        data: {
          'name': familyName,
          'family_badge': familyBadge,
          'slogan': slogan ?? '',
          'family_intro': familyIntro ?? '',
        },
      );
      final data = response as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> joinFamily(String familyId) async {
    try {
      final response = await _api.dio.post(
        '/families/join',
        data: {'familyId': familyId},
      );
      final data = response as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> leaveFamily() async {
    try {
      final response = await _api.dio.post('/families/leave');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getFamilyById(String familyId) async {
    try {
      final response = await _api.dio.get('/families/$familyId');
      final data = response as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getAllFamilies({int page = 1, String sortBy = 'total_xp'}) async {
    try {
      final response = await _api.dio.get(
        '/families/all',
        queryParameters: {'page': page, 'sortBy': sortBy},
      );
      final data = response as Map<String, dynamic>;
      return (data['data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> searchFamilies(String query, {int page = 1}) async {
    try {
      final response = await _api.dio.get(
        '/families/search',
        queryParameters: {'query': query, 'page': page},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> searchUsersToInvite(String query, {int page = 1}) async {
    try {
      final response = await _api.dio.get(
        '/families/search/users-to-invite',
        queryParameters: {'query': query, 'page': page},
      );
      final data = response as Map<String, dynamic>;
      return (data['data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> updateFamilyDetails({
    String? familyName,
    String? familyBadge,
    String? familySlogan,
    String? familyIntro,
    String? familyLogo,
    String? announcement,
  }) async {
    try {
      final response = await _api.dio.put(
        '/families/update',
        data: {
          if (familyName != null) 'family_name': familyName,
          if (familyBadge != null) 'family_badge': familyBadge,
          if (familySlogan != null) 'family_slogan': familySlogan,
          if (familyIntro != null) 'family_intro': familyIntro,
          if (familyLogo != null) 'family_logo': familyLogo,
          if (announcement != null) 'announcement': announcement,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> disbandFamily() async {
    try {
      final response = await _api.dio.post('/families/disband');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> sendInvitation({
    required String receiverUid,
    String? message,
  }) async {
    try {
      final response = await _api.dio.post(
        '/families/invite/send',
        data: {
          'receiverUid': receiverUid,
          if (message != null) 'message': message,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getMyInvitations({String status = 'pending', int page = 1}) async {
    try {
      final response = await _api.dio.get(
        '/families/invite/my',
        queryParameters: {'status': status, 'page': page},
      );
      final data = response as Map<String, dynamic>;
      return (data['data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getSentInvitations({int page = 1}) async {
    try {
      final response = await _api.dio.get(
        '/families/invite/sent',
        queryParameters: {'page': page},
      );
      final data = response as Map<String, dynamic>;
      return (data['data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> respondToInvitation({
    required String invitationId,
    required String action,
  }) async {
    try {
      final response = await _api.dio.post(
        '/families/invite/respond',
        data: {
          'invitationId': invitationId,
          'action': action,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> cancelInvitation(String invitationId) async {
    try {
      final response = await _api.dio.post(
        '/families/invite/cancel',
        data: {'invitationId': invitationId},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> assignAdmin({
    required String targetUid,
    String? adminRole,
  }) async {
    try {
      final response = await _api.dio.post(
        '/families/admin/assign',
        data: {
          'targetUid': targetUid,
          if (adminRole != null) 'adminRole': adminRole,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> removeAdmin(String targetUid) async {
    try {
      final response = await _api.dio.post(
        '/families/admin/remove',
        data: {'targetUid': targetUid},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getAdminList() async {
    try {
      final response = await _api.dio.get('/families/admin/list');
      final data = response as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> transferOwnership(String targetUid) async {
    try {
      final response = await _api.dio.post(
        '/families/admin/transfer-ownership',
        data: {'targetUid': targetUid},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getDailyTask() async {
    try {
      final response = await _api.dio.get('/families/tasks/daily');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getFamilyTasks() async {
    try {
      final response = await _api.dio.get('/families/tasks');
      final data = response as Map<String, dynamic>;
      return (data['data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> updateTaskProgress(String taskId, int progressValue) async {
    try {
      final response = await _api.dio.post(
        '/families/tasks/$taskId/progress',
        data: {'progressValue': progressValue},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getFamilyRankings({String type = 'weekly'}) async {
    try {
      final response = await _api.dio.get(
        '/families/rankings',
        queryParameters: {'type': type},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getFamilyLeaderboard({String period = 'all_time', int page = 1}) async {
    try {
      final response = await _api.dio.get(
        '/families/leaderboard',
        queryParameters: {'period': period, 'page': page},
      );
      final data = response as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> updateLeaderboard() async {
    try {
      final response = await _api.dio.post('/families/leaderboard/update');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> startStaySession({String? roomId, int seatIndex = 0}) async {
    try {
      final response = await _api.dio.post(
        '/families/stay/start',
        data: {
          if (roomId != null) 'roomId': roomId,
          'seatIndex': seatIndex,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> redeemStayReward() async {
    try {
      final response = await _api.dio.post('/families/stay/redeem');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> endStaySession() async {
    try {
      final response = await _api.dio.post('/families/stay/end');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getMyStaySession() async {
    try {
      final response = await _api.dio.get('/families/stay/my');
      final data = response as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getRewardConfig() async {
    try {
      final response = await _api.dio.get('/families/rewards/config');
      final data = response as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>? ?? data;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> updateRewardConfig({
    String? top1Reward,
    String? top2Reward,
    String? top3Reward,
    int? stayRewardCoinsPer5min,
    int? stayRewardXpPer5min,
    bool? customRewardsEnabled,
  }) async {
    try {
      final response = await _api.dio.put(
        '/families/rewards/config',
        data: {
          if (top1Reward != null) 'top1_reward': top1Reward,
          if (top2Reward != null) 'top2_reward': top2Reward,
          if (top3Reward != null) 'top3_reward': top3Reward,
          if (stayRewardCoinsPer5min != null) 'stay_reward_coins_per_5min': stayRewardCoinsPer5min,
          if (stayRewardXpPer5min != null) 'stay_reward_xp_per_5min': stayRewardXpPer5min,
          if (customRewardsEnabled != null) 'custom_rewards_enabled': customRewardsEnabled,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> setOfficialRoom(String roomId) async {
    try {
      final response = await _api.dio.post(
        '/families/room/set-official',
        data: {'roomId': roomId},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getShopItems({String? category, String? rarity}) async {
    try {
      final params = <String, dynamic>{};
      if (category != null && category != 'all') params['category'] = category;
      if (rarity != null && rarity != 'all') params['rarity'] = rarity;

      final response = await _api.dio.get(
        '/families/shop/items',
        queryParameters: params,
      );
      final data = response as Map<String, dynamic>;
      return (data['data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> purchaseShopItem(String itemId) async {
    try {
      final response = await _api.dio.post(
        '/families/shop/purchase',
        data: {'itemId': itemId},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getChatMessages(String familyId, {int page = 1, int limit = 50}) async {
    try {
      final response = await _api.dio.get(
        '/family-chat/$familyId/messages',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response as Map<String, dynamic>;
      return (data['data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> sendChatMessage({
    required String familyId,
    required String content,
    String messageType = 'text',
    String? replyTo,
    List<String> mentions = const [],
    List<Map<String, dynamic>> attachments = const [],
  }) async {
    try {
      final response = await _api.dio.post(
        '/family-chat/$familyId/messages',
        data: {
          'content': content,
          'messageType': messageType,
          'replyTo': replyTo,
          'mentions': mentions,
          'attachments': attachments,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> deleteChatMessage(String familyId, String messageId) async {
    try {
      final response = await _api.dio.delete('/family-chat/$familyId/messages/$messageId');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> pinMessage(String familyId, String messageId) async {
    try {
      final response = await _api.dio.post('/family-chat/$familyId/messages/$messageId/pin');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> addReaction(String familyId, String messageId, String emoji) async {
    try {
      final response = await _api.dio.post(
        '/family-chat/$familyId/messages/$messageId/react',
        data: {'emoji': emoji},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> createPKBattle({
    required String family1Id,
    required String family2Id,
    required String roomId,
    required String host1Uid,
    required String host2Uid,
    required DateTime scheduledAt,
  }) async {
    try {
      final response = await _api.dio.post(
        '/families/pk/create',
        data: {
          'family1Id': family1Id,
          'family2Id': family2Id,
          'roomId': roomId,
          'host1Uid': host1Uid,
          'host2Uid': host2Uid,
          'scheduledAt': scheduledAt.toIso8601String(),
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> startPKBattle(String battleId) async {
    try {
      final response = await _api.dio.post('/families/pk/$battleId/start');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> recordPKGift({
    required String battleId,
    required String userId,
    required String familyId,
    required String giftId,
    required String giftName,
    required int amount,
    required int value,
  }) async {
    try {
      final response = await _api.dio.post(
        '/families/pk/$battleId/gift',
        data: {
          'userId': userId,
          'familyId': familyId,
          'giftId': giftId,
          'giftName': giftName,
          'amount': amount,
          'value': value,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> endPKBattle(String battleId) async {
    try {
      final response = await _api.dio.post('/families/pk/$battleId/end');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getPKBattle(String battleId) async {
    try {
      final response = await _api.dio.get('/families/pk/$battleId');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> createFamilyWar({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    required List<Map<String, dynamic>> participatingFamilies,
    Map<String, dynamic>? rewards,
  }) async {
    try {
      final response = await _api.dio.post(
        '/families/war/create',
        data: {
          'title': title,
          'description': description ?? '',
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'participatingFamilies': participatingFamilies,
          'rewards': rewards ?? {},
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> startFamilyWar(String warId) async {
    try {
      final response = await _api.dio.post('/families/war/$warId/start');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> recordWarGift({
    required String warId,
    required String userId,
    required String username,
    required String familyId,
    required String giftId,
    required String giftName,
    required int value,
  }) async {
    try {
      final response = await _api.dio.post(
        '/families/war/$warId/gift',
        data: {
          'userId': userId,
          'username': username,
          'familyId': familyId,
          'giftId': giftId,
          'giftName': giftName,
          'value': value,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> endFamilyWar(String warId) async {
    try {
      final response = await _api.dio.post('/families/war/$warId/end');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getFamilyWars() async {
    try {
      final response = await _api.dio.get('/families/war');
      final data = response as Map<String, dynamic>;
      return (data['data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getMyActiveWars() async {
    try {
      final response = await _api.dio.get('/families/war/my');
      final data = response as Map<String, dynamic>;
      return (data['data'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getWarDetails(String warId) async {
    try {
      final response = await _api.dio.get('/families/war/$warId');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}