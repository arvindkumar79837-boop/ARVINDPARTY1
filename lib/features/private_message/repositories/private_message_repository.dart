import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';

import '../../../core/services/api_service.dart';
import '../../../core/utils/api_exception.dart';
import '../models/private_message_model.dart';

class PrivateMessageRepository {
  final _api = Get.find<ApiService>();
  final storage = GetStorage();
  
  String _getAuthHeader() {
    final token = storage.read('token') ?? '';
    return 'Bearer $token';
  }

  Future<List<PrivateChatUser>> getPrivateChats({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        '/messages/private/chats',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((chat) => PrivateChatUser.fromJson(chat as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch chats');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<PrivateMessage>> getPrivateMessages(
    String userId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _api.get(
        '/messages/private/$userId',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((msg) => PrivateMessage.fromJson(msg as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch messages');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<PrivateMessage> sendMessage({
    required String recipientId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      final response = await _api.post(
        '/messages/private/send',
        data: {
          'recipientId': recipientId,
          'content': content,
          'messageType': messageType,
        },
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        return PrivateMessage.fromJson(data['data']);
      }
      throw Exception('Failed to send message');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<PrivateMessage> uploadMedia({
    required String recipientId,
    required String filePath,
    required String messageType, // image, video, voice, file
  }) async {
    try {
      final formData = FormData.fromMap({
        'recipientId': recipientId,
        'messageType': messageType,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _api.post(
        '/messages/private/upload',
        data: formData,
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        return PrivateMessage.fromJson(data['data']);
      }
      throw Exception('Upload failed');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<void> markAsRead(String messageId) async {
    try {
      await _api.post(
        '/messages/private/$messageId/read',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _api.post(
        '/messages/private/$userId/read-all',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _api.delete(
        '/messages/private/$messageId',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<void> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      await _api.put(
        '/messages/private/$messageId',
        data: {'content': newContent},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<UserStatus> getUserStatus(String userId) async {
    try {
      final response = await _api.get(
        '/users/$userId/status',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        return UserStatus.fromJson(data['data']);
      }
      throw Exception('Failed to fetch status');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<void> setTypingStatus(String userId, bool isTyping) async {
    try {
      await _api.post(
        '/messages/private/$userId/typing',
        data: {'isTyping': isTyping},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    try {
      await _api.post(
        '/users/status',
        data: {'isOnline': isOnline},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}