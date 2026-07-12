// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/chat/models/chat_model.dart
// ARVIND PARTY - CHAT MODELS
// ═══════════════════════════════════════════════════════════════════════════

class ChatModel {
  final String id;
  final String name;
  final String? avatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int? unreadCount;
  final bool isOnline;

  ChatModel({
    required this.id,
    required this.name,
    this.avatar,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount,
    this.isOnline = false,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      lastMessage: json['lastMessage']?.toString(),
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'].toString())
          : null,
      unreadCount: json['unreadCount'] is int ? json['unreadCount'] : int.tryParse(json['unreadCount']?.toString() ?? '0'),
      isOnline: json['isOnline'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime?.toIso8601String(),
    'unreadCount': unreadCount,
    'isOnline': isOnline,
  };
}

enum MessageType { text, image, video, audio, sticker, gift, system }

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String text;
  final String? mediaUrl;
  final String? stickerUrl;
  final DateTime createdAt;
  final bool isRead;
  final String? replyToId;
  final MessageModel? repliedToMessage;
  final MessageType type;
  final bool isDeleted;
  final bool isPinned;
  final List<String> reactions;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.text,
    this.mediaUrl,
    this.stickerUrl,
    required this.createdAt,
    this.isRead = false,
    this.replyToId,
    this.repliedToMessage,
    this.type = MessageType.text,
    this.isDeleted = false,
    this.isPinned = false,
    this.reactions = const [],
    this.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      chatId: json['chatId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString(),
      stickerUrl: json['stickerUrl'] ?? json['stickerId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] == true,
      replyToId: json['replyToId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'senderId': senderId,
    'senderName': senderName,
    'text': text,
    'mediaUrl': mediaUrl,
    'stickerUrl': stickerUrl,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'replyToId': replyToId,
  };
}
