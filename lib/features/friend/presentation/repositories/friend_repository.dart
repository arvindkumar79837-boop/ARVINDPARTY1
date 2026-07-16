import 'package:get/get.dart';

import '../../../../core/services/api_service.dart';
import '../../models/friend_model.dart';

class FriendRepository {
  final _api = Get.find<ApiService>();

  Future<List<FriendModel>> getFriends() async {
    try {
      final response = await _api.get('/friends');
      return (response['data'] as List).map((e) => FriendModel.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<List<FriendModel>> getFollowers() async {
    try {
      final response = await _api.get('/friends/followers');
      return (response['data'] as List).map((e) => FriendModel.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<List<FriendModel>> getFollowing() async {
    try {
      final response = await _api.get('/friends/following');
      return (response['data'] as List).map((e) => FriendModel.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<List<FriendModel>> getMutualFriends(String userId) async {
    try {
      final response = await _api.get('/friends/mutual', queryParameters: {'userId': userId});
      return (response['data'] as List).map((e) => FriendModel.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<List<FriendRequestModel>> getIncomingRequests() async {
    try {
      final response = await _api.get('/friends/requests/incoming');
      return (response['data'] as List).map((e) => FriendRequestModel.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<List<FriendRequestModel>> getOutgoingRequests() async {
    try {
      final response = await _api.get('/friends/requests/outgoing');
      return (response['data'] as List).map((e) => FriendRequestModel.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<List<FriendModel>> searchUsers(String query) async {
    try {
      final response = await _api.get('/friends/search', queryParameters: {'q': query});
      return (response['data'] as List).map((e) => FriendModel.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<void> sendFriendRequest(String userId) async => await _api.post('/friends/request', data: {'userId': userId});
  Future<void> acceptFriendRequest(String requestId) async => await _api.put('/friends/request/$requestId/accept');
  Future<void> rejectFriendRequest(String requestId) async => await _api.delete('/friends/request/$requestId');
  Future<void> followUser(String userId) async => await _api.post('/friends/follow', data: {'userId': userId});
  Future<void> unfollowUser(String userId) async => await _api.delete('/friends/follow', data: {'userId': userId});
  Future<void> removeFriend(String userId) async => await _api.delete('/friends/$userId');
}