// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/chat/presentation/repositories/chat_repository.dart
// ARVIND PARTY - CHAT REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../models/chat_model.dart';

class ChatRepository extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<List<Map<String, dynamic>>> fetchMessages(String roomId) async {
    try {
      final response = await _api.get('${ApiConstants.chat}/$roomId/messages');
      if (response is Map && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> sendMessage(String roomId, String text) async {
    try {
      await _api.post('${ApiConstants.chat}/$roomId/messages', body: {'text': text});
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchConversations() async {
    try {
      final response = await _api.get(ApiConstants.chat);
      if (response is Map && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createConversation(String participantId, {String? initialMessage}) async {
    try {
      final response = await _api.post('${ApiConstants.chat}/conversation', body: {
        'participantId': participantId,
        if (initialMessage != null) 'initialMessage': initialMessage,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    try {
      final response = await _api.get('${ApiConstants.chat}/conversation/$conversationId');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMessage(String roomId, String messageId) async {
    try {
      await _api.delete('${ApiConstants.chat}/$roomId/messages/$messageId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(String roomId) async {
    try {
      await _api.post('${ApiConstants.chat}/$roomId/read');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MessageModel>> fetchMessageHistory(String roomId, {int page = 1, int limit = 50}) async {
    try {
      final response = await _api.get(
        '${ApiConstants.chat}/$roomId/messages',
        query: {'page': page, 'limit': limit},
      );
      if (response is Map && response['data'] is List) {
        final messages = (response['data'] as List)
            .map((m) => MessageModel.fromJson(Map<String, dynamic>.from(m)))
            .toList();
        return messages;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> sendMediaMessage(String roomId, String filePath, String type, {String? text}) async {
    try {
      await _api.uploadFile(
        '${ApiConstants.chat}/$roomId/messages/media',
        filePath,
        'media',
        extraFields: {
          'type': type,
          if (text != null) 'text': text,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendGiftMessage(String roomId, String giftId, String recipientId) async {
    try {
      await _api.post('${ApiConstants.chat}/$roomId/messages/gift', body: {
        'giftId': giftId,
        'recipientId': recipientId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reportMessage(String roomId, String messageId, String reason) async {
    try {
      await _api.post('${ApiConstants.chat}/$roomId/messages/$messageId/report', body: {
        'reason': reason,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChatModel>> searchConversations(String query) async {
    try {
      final response = await _api.get('${ApiConstants.chat}/search', query: {'q': query});
      if (response is Map && response['data'] is List) {
        return (response['data'] as List)
            .map((c) => ChatModel.fromJson(Map<String, dynamic>.from(c)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _api.delete('${ApiConstants.chat}/conversation/$conversationId');
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _api.get('${ApiConstants.chat}/unread-count');
      if (response is Map && response['data'] != null) {
        return response['data']['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> typing(String roomId) async {
    try {
      await _api.post('${ApiConstants.chat}/$roomId/typing');
    } catch (e) {
      rethrow;
    }
  }
}
