import 'package:get/get.dart';

import '../../../core/services/api_service.dart';
import '../models/block_model.dart';

class BlockRepository {
  final _api = Get.find<ApiService>();

  Future<List<BlockedUserModel>> getBlockedUsers() async {
    try {
      final response = await _api.get('/block');
      return (response['data'] as List).map((e) => BlockedUserModel.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<List<MutedUserModel>> getMutedUsers() async {
    try {
      final response = await _api.get('/mute');
      return (response['data'] as List).map((e) => MutedUserModel.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<void> blockUser(String userId) async => await _api.post('/block', body: {'targetUserId': userId});
  Future<void> unblockUser(String userId) async => await _api.delete('/block/$userId');
  Future<void> muteUser(String userId, MuteDuration duration) async {
    int seconds;
    switch (duration) {
      case MuteDuration.fifteenMinutes: seconds = 15 * 60; break;
      case MuteDuration.oneHour: seconds = 60 * 60; break;
      case MuteDuration.sixHours: seconds = 6 * 60 * 60; break;
      case MuteDuration.oneDay: seconds = 24 * 60 * 60; break;
      case MuteDuration.oneWeek: seconds = 7 * 24 * 60 * 60; break;
      case MuteDuration.forever: seconds = -1; break;
    }
    await _api.post('/mute', body: {'targetUserId': userId, 'durationSeconds': seconds});
  }
  Future<void> unmuteUser(String userId) async => await _api.delete('/mute/$userId');
}