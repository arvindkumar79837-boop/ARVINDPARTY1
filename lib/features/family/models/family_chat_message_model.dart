class FamilyChatMessageModel {
  final String messageId;
  final String familyId;
  final String senderUid;
  final String senderName;
  final String senderAvatar;
  final String messageType;
  final String content;
  final String? replyTo;
  final List<ReactionModel> reactions;
  final bool isDeleted;
  final DateTime createdAt;

  FamilyChatMessageModel({
    required this.messageId,
    required this.familyId,
    required this.senderUid,
    required this.senderName,
    required this.senderAvatar,
    required this.messageType,
    required this.content,
    this.replyTo,
    required this.reactions,
    required this.isDeleted,
    required this.createdAt,
  });

  factory FamilyChatMessageModel.fromJson(Map<String, dynamic> json) {
    return FamilyChatMessageModel(
      messageId: json['messageId'] ?? '',
      familyId: json['familyId'] ?? '',
      senderUid: json['senderUid'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'] ?? '',
      messageType: json['messageType'] ?? 'text',
      content: json['content'] ?? '',
      replyTo: json['replyTo'],
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((r) => ReactionModel.fromJson(r as Map<String, dynamic>))
          .toList() ?? [],
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'familyId': familyId,
      'senderUid': senderUid,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'messageType': messageType,
      'content': content,
      'replyTo': replyTo,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ReactionModel {
  final String emoji;
  final List<String> users;
  final int count;

  ReactionModel({
    required this.emoji,
    required this.users,
    required this.count,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      emoji: json['emoji'] ?? '',
      users: List<String>.from(json['users'] ?? []),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'users': users,
      'count': count,
    };
  }
}