// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/models/room_models.dart
// ARVIND PARTY - ROOM MODELS (Extended: Room Varieties, Seats, PK, Tasks, Cosmetics)
// ═══════════════════════════════════════════════════════════════════════════

class RoomModel {
  final String id;
  final String name;
  final String? title;
  final String hostId;
  final String? hostName;
  final String? hostAvatar;
  final int maxMembers;
  final int currentMembers;
  final int onlineUsers;
  final int seatCount;
  final bool isLive;
  final String? roomPassword;
  final String? password;
  final String? roomType;
  final String? roomCategory;
  final String? topic;
  final String? banner;
  final List<String> tags;
  final String? pinnedMessage;
  final String? announcement;
  final String? welcomeMessage;
  final String? description;
  final String? coverImage;
  final String? language;
  final String? backgroundUrl;
  final String? themeColor;
  final bool? isAnimated;
  final String? liveKitRoom;
  final int? totalGiftPoints;
  final int? totalTrafficMinutes;
  final int? pkPoints;
  final int? pkWins;
  final int? pkLosses;
  final int? rankPoints;
  final int? lootBoxLevel;
  final int? lootBoxPoints;
  final List<SeatData> seats;
  final List<RoomTask>? dailyTasks;
  final PKChallenge? currentPkChallenge;

  RoomModel({
    required this.id,
    required this.name,
    this.title,
    required this.hostId,
    this.hostName,
    this.hostAvatar,
    this.maxMembers = 10,
    this.currentMembers = 0,
    this.onlineUsers = 0,
    this.seatCount = 10,
    this.isLive = false,
    this.roomPassword,
    this.password,
    this.roomType,
    this.roomCategory,
    this.topic,
    this.banner,
    this.tags = const [],
    this.pinnedMessage,
    this.announcement,
    this.welcomeMessage,
    this.description,
    this.coverImage,
    this.language,
    this.backgroundUrl,
    this.themeColor,
    this.isAnimated,
    this.liveKitRoom,
    this.totalGiftPoints,
    this.totalTrafficMinutes,
    this.pkPoints,
    this.pkWins,
    this.pkLosses,
    this.rankPoints,
    this.lootBoxLevel,
    this.lootBoxPoints,
    this.seats = const [],
    this.dailyTasks,
    this.currentPkChallenge,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? json['roomId'] ?? json['_id'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      title: json['title'] ?? json['name'],
      hostId: json['hostId'] ?? json['ownerId']?['_id'] ?? json['ownerId'] ?? '',
      hostName: json['hostName'] ?? json['ownerId']?['name'] ?? json['ownerId']?['username'],
      hostAvatar: json['ownerId']?['avatar'],
      maxMembers: json['maxMembers'] ?? json['seatCount'] ?? 10,
      currentMembers: json['currentMembers'] ?? json['activeUsers'] ?? 0,
      onlineUsers: json['onlineUsers'] ?? json['activeUsers'] ?? 0,
      seatCount: json['seatCount'] ?? 8,
      isLive: json['isLive'] ?? false,
      roomPassword: json['roomPassword'],
      password: json['password'],
      roomType: json['roomType'] ?? json['type'],
      roomCategory: json['roomCategory'],
      topic: json['topic'],
      banner: json['banner'] ?? json['coverImage'],
      tags: List<String>.from(json['tags'] ?? []),
      pinnedMessage: json['pinnedMessage'],
      announcement: json['announcement'],
      welcomeMessage: json['welcomeMessage'],
      description: json['description'],
      coverImage: json['coverImage'],
      language: json['language'],
      backgroundUrl: json['backgroundUrl'] ?? json['cosmetics']?['backgroundUrl'],
      themeColor: json['themeColor'] ?? json['cosmetics']?['themeColor'],
      isAnimated: json['isAnimated'] ?? json['cosmetics']?['isAnimated'],
      liveKitRoom: json['liveKitRoom'],
      totalGiftPoints: json['totalGiftPoints'] ?? 0,
      totalTrafficMinutes: json['totalTrafficMinutes'] ?? 0,
      pkPoints: json['pkPoints'] ?? 0,
      pkWins: json['pkWins'] ?? 0,
      pkLosses: json['pkLosses'] ?? 0,
      rankPoints: json['rankPoints'] ?? 0,
      lootBoxLevel: json['lootBoxLevel'] ?? 1,
      lootBoxPoints: json['lootBoxPoints'] ?? 0,
      seats: (json['seats'] as List?)?.map((s) => SeatData.fromJson(Map<String, dynamic>.from(s))).toList() ?? [],
      dailyTasks: (json['dailyTasks'] as List?)?.map((t) => RoomTask.fromJson(Map<String, dynamic>.from(t))).toList(),
      currentPkChallenge: json['currentPkChallenge'] != null ? PKChallenge.fromJson(Map<String, dynamic>.from(json['currentPkChallenge'])) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'title': title,
    'hostId': hostId,
    'hostName': hostName,
    'maxMembers': maxMembers,
    'currentMembers': currentMembers,
    'onlineUsers': onlineUsers,
    'seatCount': seatCount,
    'isLive': isLive,
    'roomPassword': roomPassword,
    'password': password,
    'roomType': roomType,
    'roomCategory': roomCategory,
    'topic': topic,
    'banner': banner,
    'tags': tags,
    'pinnedMessage': pinnedMessage,
    'announcement': announcement,
    'welcomeMessage': welcomeMessage,
    'description': description,
    'coverImage': coverImage,
    'language': language,
    'backgroundUrl': backgroundUrl,
    'themeColor': themeColor,
    'isAnimated': isAnimated,
    'liveKitRoom': liveKitRoom,
    'totalGiftPoints': totalGiftPoints,
    'totalTrafficMinutes': totalTrafficMinutes,
    'pkPoints': pkPoints,
    'pkWins': pkWins,
    'pkLosses': pkLosses,
    'rankPoints': rankPoints,
    'lootBoxLevel': lootBoxLevel,
    'lootBoxPoints': lootBoxPoints,
    'seats': seats.map((s) => s.toJson()).toList(),
  };

  RoomModel copyWith({
    String? id,
    String? name,
    String? title,
    String? hostId,
    String? hostName,
    String? hostAvatar,
    int? maxMembers,
    int? currentMembers,
    int? onlineUsers,
    int? seatCount,
    bool? isLive,
    String? roomPassword,
    String? password,
    String? roomType,
    String? roomCategory,
    String? topic,
    String? banner,
    List<String>? tags,
    String? pinnedMessage,
    String? announcement,
    String? welcomeMessage,
    String? description,
    String? coverImage,
    String? language,
    String? backgroundUrl,
    String? themeColor,
    bool? isAnimated,
    String? liveKitRoom,
    int? totalGiftPoints,
    int? totalTrafficMinutes,
    int? pkPoints,
    int? pkWins,
    int? pkLosses,
    int? rankPoints,
    int? lootBoxLevel,
    int? lootBoxPoints,
    List<SeatData>? seats,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      maxMembers: maxMembers ?? this.maxMembers,
      currentMembers: currentMembers ?? this.currentMembers,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      seatCount: seatCount ?? this.seatCount,
      isLive: isLive ?? this.isLive,
      roomPassword: roomPassword ?? this.roomPassword,
      password: password ?? this.password,
      roomType: roomType ?? this.roomType,
      roomCategory: roomCategory ?? this.roomCategory,
      topic: topic ?? this.topic,
      banner: banner ?? this.banner,
      tags: tags ?? this.tags,
      pinnedMessage: pinnedMessage ?? this.pinnedMessage,
      announcement: announcement ?? this.announcement,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      language: language ?? this.language,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
      themeColor: themeColor ?? this.themeColor,
      isAnimated: isAnimated ?? this.isAnimated,
      liveKitRoom: liveKitRoom ?? this.liveKitRoom,
      totalGiftPoints: totalGiftPoints ?? this.totalGiftPoints,
      totalTrafficMinutes: totalTrafficMinutes ?? this.totalTrafficMinutes,
      pkPoints: pkPoints ?? this.pkPoints,
      pkWins: pkWins ?? this.pkWins,
      pkLosses: pkLosses ?? this.pkLosses,
      rankPoints: rankPoints ?? this.rankPoints,
      lootBoxLevel: lootBoxLevel ?? this.lootBoxLevel,
      lootBoxPoints: lootBoxPoints ?? this.lootBoxPoints,
      seats: seats ?? this.seats,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final String time;
  final bool isMe;
  final String? senderAvatar;
  final bool isVip;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.time,
    this.isMe = false,
    this.senderAvatar,
    this.isVip = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      message: json['message']?.toString() ?? json['text']?.toString() ?? '',
      time: json['time']?.toString() ?? json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      isMe: json['isMe'] ?? false,
      senderAvatar: json['senderAvatar']?.toString(),
      isVip: json['isVip'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'message': message,
    'time': time,
    'isMe': isMe,
    'senderAvatar': senderAvatar,
    'isVip': isVip,
  };
}

class RaiseHandRequest {
  final String requestId;
  final String userId;
  final String userName;
  final String? avatar;
  final DateTime requestedAt;

  RaiseHandRequest({
    required this.requestId,
    required this.userId,
    required this.userName,
    this.avatar,
    required this.requestedAt,
  });

  factory RaiseHandRequest.fromJson(Map<String, dynamic> json) {
    return RaiseHandRequest(
      requestId: json['requestId'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      avatar: json['avatar'],
      requestedAt: json['requestedAt'] != null ? DateTime.parse(json['requestedAt']) : DateTime.now(),
    );
  }
}

enum MemberRole {
  host,
  coHost,
  moderator,
  speaker,
  listener,
  muted,
  visitor,
  owner,
  admin,
  member,
}

enum VoiceEffect {
  none,
  robot,
  echo,
  reverb,
  highPitch,
  lowPitch,
}

enum SeatStatus {
  empty,
  occupied,
  locked,
  reserved,
}

enum RoomType {
  voice,
  video,
  chat,
  gaming,
  music,
  podcast,
  interview,
  meeting,
  event,
  social,
}

class RoomMemberModel {
  final String id;
  final String userId;
  final String userName;
  final MemberRole role;
  final bool isOnline;
  final String? avatar;
  final int? userLevel;

  const RoomMemberModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.role,
    this.isOnline = false,
    this.avatar,
    this.userLevel,
  });

  RoomMemberModel copyWith({
    String? id,
    String? userId,
    String? userName,
    MemberRole? role,
    bool? isOnline,
    String? avatar,
    int? userLevel,
  }) {
    return RoomMemberModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      avatar: avatar ?? this.avatar,
      userLevel: userLevel ?? this.userLevel,
    );
  }
}

class SeatModel {
  final int index;
  final String? userId;
  final String? userName;
  final String? avatar;
  final bool isOccupied;
  final bool isLocked;
  final bool isMuted;

  const SeatModel({
    required this.index,
    this.userId,
    this.userName,
    this.avatar,
    this.isOccupied = false,
    this.isLocked = false,
    this.isMuted = false,
  });

  String get seatNumber => '${index + 1}';

  bool get isHost => userId == 'host';

  bool get isSpeaking => false;

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      index: json['index'] ?? json['seatIndex'] ?? 0,
      userId: json['userId']?.toString(),
      userName: json['userName']?.toString(),
      avatar: json['avatar']?.toString() ?? json['userAvatar']?.toString(),
      isOccupied: json['isOccupied'] ?? (json['userId'] != null),
      isLocked: json['isLocked'] ?? false,
      isMuted: json['isMuted'] ?? false,
    );
  }

  SeatModel copyWith({
    int? index,
    String? userId,
    String? userName,
    String? avatar,
    bool? isOccupied,
    bool? isLocked,
    bool? isMuted,
  }) {
    return SeatModel(
      index: index ?? this.index,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatar: avatar ?? this.avatar,
      isOccupied: isOccupied ?? this.isOccupied,
      isLocked: isLocked ?? this.isLocked,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class RoomPermissionModel {
  final bool canSpeak;
  final bool canShareVideo;
  final bool canSendGifts;
  final bool canChat;
  final bool canInvite;

  const RoomPermissionModel({
    this.canSpeak = true,
    this.canShareVideo = false,
    this.canSendGifts = true,
    this.canChat = true,
    this.canInvite = false,
  });

  factory RoomPermissionModel.forRole(MemberRole role) {
    switch (role) {
      case MemberRole.host:
      case MemberRole.coHost:
      case MemberRole.admin:
        return const RoomPermissionModel(canShareVideo: true, canInvite: true);
      case MemberRole.moderator:
        return const RoomPermissionModel();
      case MemberRole.speaker:
        return const RoomPermissionModel(canShareVideo: true);
      case MemberRole.listener:
      case MemberRole.muted:
      case MemberRole.visitor:
      case MemberRole.member:
      default:
        return const RoomPermissionModel(canSpeak: false, canSendGifts: false);
    }
  }
}

class SeatData {
  final int seatIndex;
  final String? userId;
  final String? userName;
  final String? userAvatar;
  final bool isLocked;
  final bool isMuted;
  final bool isHost;
  final String role;
  final DateTime? joinedAt;

  const SeatData({
    required this.seatIndex,
    this.userId,
    this.userName,
    this.userAvatar,
    this.isLocked = false,
    this.isMuted = false,
    this.isHost = false,
    this.role = 'empty',
    this.joinedAt,
  });

  int get index => seatIndex;

  bool get isOccupied => userId != null && userId!.isNotEmpty;

  String? get avatar => userAvatar;

  String get seatNumber => '${seatIndex + 1}';

  SeatStatus get status {
    if (isLocked) return SeatStatus.locked;
    if (isOccupied) return SeatStatus.occupied;
    return SeatStatus.empty;
  }

  int get seatId => seatIndex;

  bool get isHostSeat => isHost;

  bool get isSpeaking => false;

  factory SeatData.fromJson(Map<String, dynamic> json) {
    return SeatData(
      seatIndex: json['seatIndex'] ?? json['index'] ?? 0,
      userId: json['userId']?.toString(),
      userName: json['userName']?.toString(),
      userAvatar: json['userAvatar']?.toString() ?? json['avatar']?.toString(),
      isLocked: json['isLocked'] ?? false,
      isMuted: json['isMuted'] ?? false,
      isHost: json['isHost'] ?? false,
      role: json['role']?.toString() ?? (json['userId'] != null ? 'broadcaster' : 'empty'),
      joinedAt: json['joinedAt'] != null ? DateTime.tryParse(json['joinedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'seatIndex': seatIndex,
    'userId': userId,
    'userName': userName,
    'userAvatar': userAvatar,
    'isLocked': isLocked,
    'isMuted': isMuted,
    'isHost': isHost,
    'role': role,
    'joinedAt': joinedAt?.toIso8601String(),
  };

  SeatData copyWith({
    int? seatIndex,
    String? userId,
    String? userName,
    String? userAvatar,
    bool? isLocked,
    bool? isMuted,
    bool? isHost,
    String? role,
    DateTime? joinedAt,
  }) {
    return SeatData(
      seatIndex: seatIndex ?? this.seatIndex,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      isLocked: isLocked ?? this.isLocked,
      isMuted: isMuted ?? this.isMuted,
      isHost: isHost ?? this.isHost,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

class GiftAnimation {
  final String giftId;
  final String giftName;
  final String senderName;
  final String? animationUrl;
  final String? giftImageUrl;
  final int quantity;

  const GiftAnimation({
    required this.giftId,
    this.giftName = 'Gift',
    required this.senderName,
    this.animationUrl,
    this.giftImageUrl,
    this.quantity = 1,
  });
}

// ─── Room Task Model ────────────────────────────────────────────
class RoomTask {
  final String taskId;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final int rewardCoins;
  final int rewardXp;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? expiresAt;

  const RoomTask({
    required this.taskId,
    required this.title,
    this.description = '',
    this.targetValue = 1,
    this.currentValue = 0,
    this.rewardCoins = 0,
    this.rewardXp = 0,
    this.isCompleted = false,
    this.completedAt,
    this.expiresAt,
  });

  double get progressPercent => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  factory RoomTask.fromJson(Map<String, dynamic> json) {
    return RoomTask(
      taskId: json['taskId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetValue: json['targetValue'] ?? 1,
      currentValue: json['currentValue'] ?? 0,
      rewardCoins: json['rewardCoins'] ?? 0,
      rewardXp: json['rewardXp'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString()) : null,
    );
  }

  RoomTask copyWith({
    String? taskId,
    String? title,
    String? description,
    int? targetValue,
    int? currentValue,
    int? rewardCoins,
    int? rewardXp,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? expiresAt,
  }) {
    return RoomTask(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      rewardXp: rewardXp ?? this.rewardXp,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

// ─── PK Challenge Model ─────────────────────────────────────────
class PKChallenge {
  final String challengeId;
  final String challengerRoomId;
  final String challengerRoomName;
  final String opponentRoomId;
  final String opponentRoomName;
  final int challengerScore;
  final int opponentScore;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final String? winnerRoomId;

  const PKChallenge({
    required this.challengeId,
    required this.challengerRoomId,
    this.challengerRoomName = '',
    required this.opponentRoomId,
    this.opponentRoomName = '',
    this.challengerScore = 0,
    this.opponentScore = 0,
    required this.startTime,
    this.endTime,
    this.status = 'active',
    this.winnerRoomId,
  });

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';

  factory PKChallenge.fromJson(Map<String, dynamic> json) {
    return PKChallenge(
      challengeId: json['challengeId'] ?? '',
      challengerRoomId: json['challengerRoomId'] ?? '',
      challengerRoomName: json['challengerRoomName'] ?? '',
      opponentRoomId: json['opponentRoomId'] ?? '',
      opponentRoomName: json['opponentRoomName'] ?? '',
      challengerScore: json['challengerScore'] ?? 0,
      opponentScore: json['opponentScore'] ?? 0,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime'].toString()) : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime'].toString()) : null,
      status: json['status'] ?? 'pending',
      winnerRoomId: json['winnerRoomId'],
    );
  }
}

// ─── Room Background Model ──────────────────────────────────────
class RoomBackground {
  final String backgroundId;
  final String backgroundName;
  final String backgroundUrl;
  final int costCoins;
  final bool isAnimated;
  final String? themeColor;

  const RoomBackground({
    required this.backgroundId,
    required this.backgroundName,
    required this.backgroundUrl,
    this.costCoins = 0,
    this.isAnimated = false,
    this.themeColor,
  });

  factory RoomBackground.fromJson(Map<String, dynamic> json) {
    return RoomBackground(
      backgroundId: json['backgroundId'] ?? '',
      backgroundName: json['backgroundName'] ?? '',
      backgroundUrl: json['backgroundUrl'] ?? '',
      costCoins: json['costCoins'] ?? 0,
      isAnimated: json['isAnimated'] ?? false,
      themeColor: json['themeColor'],
    );
  }
}

// ─── Room Ranking Entry ─────────────────────────────────────────
class RoomRankingEntry {
  final String roomId;
  final String title;
  final String? ownerName;
  final String? ownerAvatar;
  final String? roomType;
  final int totalGiftPoints;
  final int totalTrafficMinutes;
  final int pkPoints;
  final int pkWins;
  final int pkLosses;
  final int rankPoints;
  final int activeUsers;
  final String? backgroundUrl;

  const RoomRankingEntry({
    required this.roomId,
    required this.title,
    this.ownerName,
    this.ownerAvatar,
    this.roomType,
    this.totalGiftPoints = 0,
    this.totalTrafficMinutes = 0,
    this.pkPoints = 0,
    this.pkWins = 0,
    this.pkLosses = 0,
    this.rankPoints = 0,
    this.activeUsers = 0,
    this.backgroundUrl,
  });

  factory RoomRankingEntry.fromJson(Map<String, dynamic> json) {
    return RoomRankingEntry(
      roomId: json['roomId'] ?? '',
      title: json['title'] ?? '',
      ownerName: json['ownerId']?['name'] ?? json['ownerId']?['username'],
      ownerAvatar: json['ownerId']?['avatar'],
      roomType: json['roomType'],
      totalGiftPoints: json['totalGiftPoints'] ?? 0,
      totalTrafficMinutes: json['totalTrafficMinutes'] ?? 0,
      pkPoints: json['pkPoints'] ?? 0,
      pkWins: json['pkWins'] ?? 0,
      pkLosses: json['pkLosses'] ?? 0,
      rankPoints: json['rankPoints'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      backgroundUrl: json['cosmetics']?['backgroundUrl'],
    );
  }
}