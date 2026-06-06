class ChatMessage {
  final String messageId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String message;
  final bool isVip;
  final DateTime timestamp;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    this.isVip = false,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Guest',
      senderAvatar: json['senderAvatar'] ?? '',
      message: json['message'] ?? '',
      isVip: json['isVip'] ?? false,
      timestamp: DateTime.now(), // Sockets are real-time, so now is fine.
    );
  }
}

class Seat {
  final int seatIndex;
  final String? userId;
  final String? userName;
  final String? userAvatar;
  final bool isMuted;
  final bool isLocked;

  Seat(
      {required this.seatIndex,
      this.userId,
      this.userName,
      this.userAvatar,
      this.isMuted = true,
      this.isLocked = false});

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
        seatIndex: json['seatIndex'],
        userId: json['userId'],
        userName: json['userName'],
        userAvatar: json['userAvatar'],
        isMuted: json['isMuted'] ?? true,
        isLocked: json['isLocked'] ?? false);
  }
}

class GiftAnimation {
  final String giftId;
  final String giftImageUrl; // For the animation file (e.g., SVGA)
  final String senderName;
  final int quantity;

  GiftAnimation(
      {required this.giftId,
      required this.giftImageUrl,
      required this.senderName,
      required this.quantity});
}
