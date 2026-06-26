// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/gift/models/gift_model.dart
// ARVIND PARTY - GIFT MODEL (Extended: STATIC, SVGA, 3D, LUCKY, TREASURE, VEHICLE, CASTLE, FRAME, AVATAR, FESTIVAL, COMBO)
// ═══════════════════════════════════════════════════════════════════════════

enum GiftType { static, animated, svga, mp4, combo, lucky, treasure, vehicle, castle, frame, avatar, festival }
enum GiftCategory { hot, basic, premium, luxury, vip, lucky, festival }

class GiftModel {
  final String id;
  final String giftName;
  final String? description;
  final GiftType type;
  final GiftCategory category;
  final double coinPrice;
  final double diamondValue;
  final String previewImageUrl;
  final String? animationUrl;
  final String? svgaUrl;
  final String? animationJsonUrl;
  final int? comboCount;
  final String? comboAnimationUrl;
  final bool comboEnabled;
  final List<int> comboMultipliers;
  final bool isLucky;
  final List<int> luckyMultiplier;
  final int? luckyMinCoins;
  final int? luckyMaxCoins;
  final bool isTreasure;
  final int? treasurePoolCoins;
  final int? treasureDurationSeconds;
  final int? treasureMaxClaimers;
  final String? vehicleModelUrl;
  final String? castleModelUrl;
  final int? displayDurationSeconds;
  final String? frameId;
  final String? frameImageUrl;
  final int? frameDurationDays;
  final String? avatarCustomizationId;
  final String? festivalId;
  final String? festivalName;
  final bool isLimitedEdition;
  final int? requiredVipLevel;
  final String? roomId;
  final bool isAvailable;

  GiftModel({
    required this.id,
    required this.giftName,
    this.description,
    this.type = GiftType.static,
    this.category = GiftCategory.basic,
    this.coinPrice = 1,
    this.diamondValue = 1,
    this.previewImageUrl = '',
    this.animationUrl,
    this.svgaUrl,
    this.animationJsonUrl,
    this.comboCount,
    this.comboAnimationUrl,
    this.comboEnabled = false,
    this.comboMultipliers = const [1, 5, 10, 99, 999],
    this.isLucky = false,
    this.luckyMultiplier = const [1, 5, 10, 100, 500],
    this.luckyMinCoins,
    this.luckyMaxCoins,
    this.isTreasure = false,
    this.treasurePoolCoins,
    this.treasureDurationSeconds,
    this.treasureMaxClaimers,
    this.vehicleModelUrl,
    this.castleModelUrl,
    this.displayDurationSeconds,
    this.frameId,
    this.frameImageUrl,
    this.frameDurationDays,
    this.avatarCustomizationId,
    this.festivalId,
    this.festivalName,
    this.isLimitedEdition = false,
    this.requiredVipLevel,
    this.roomId,
    this.isAvailable = true,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['_id'] ?? json['id'] ?? '',
      giftName: json['giftName'] ?? json['name'] ?? '',
      description: json['description'],
      type: _parseGiftType(json['giftType'] ?? json['type'] ?? 'STATIC'),
      category: _parseGiftCategory(json['category'] ?? 'BASIC'),
      coinPrice: (json['coinPrice'] ?? json['price'] ?? 0).toDouble(),
      diamondValue: (json['diamondValue'] ?? 0).toDouble(),
      previewImageUrl: json['previewImageUrl'] ?? json['imageUrl'] ?? '',
      animationUrl: json['animationUrl'],
      svgaUrl: json['svgaUrl'],
      animationJsonUrl: json['animationJsonUrl'],
      comboCount: json['comboCount'],
      comboAnimationUrl: json['comboAnimationUrl'],
      comboEnabled: json['comboEnabled'] ?? false,
      comboMultipliers: json['comboMultipliers'] != null ? List<int>.from(json['comboMultipliers']) : [1, 5, 10, 99, 999],
      isLucky: json['isLucky'] ?? false,
      luckyMultiplier: json['luckyMultiplier'] != null ? List<int>.from(json['luckyMultiplier']) : [1, 5, 10, 100, 500],
      luckyMinCoins: json['luckyMinCoins'],
      luckyMaxCoins: json['luckyMaxCoins'],
      isTreasure: json['isTreasure'] ?? false,
      treasurePoolCoins: json['treasurePoolCoins'],
      treasureDurationSeconds: json['treasureDurationSeconds'],
      treasureMaxClaimers: json['treasureMaxClaimers'],
      vehicleModelUrl: json['vehicleModelUrl'],
      castleModelUrl: json['castleModelUrl'],
      displayDurationSeconds: json['displayDurationSeconds'],
      frameId: json['frameId'],
      frameImageUrl: json['frameImageUrl'],
      frameDurationDays: json['frameDurationDays'],
      avatarCustomizationId: json['avatarCustomizationId'],
      festivalId: json['festivalId'],
      festivalName: json['festivalName'],
      isLimitedEdition: json['isLimitedEdition'] ?? false,
      requiredVipLevel: json['requiredVipLevel'],
      roomId: json['roomId'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  static GiftType _parseGiftType(String type) {
    switch (type.toUpperCase()) {
      case 'STATIC': return GiftType.static;
      case 'ANIMATED': return GiftType.animated;
      case 'SVGA': return GiftType.svga;
      case '3D': return GiftType.svga;
      case 'COMBO': return GiftType.combo;
      case 'LUCKY': return GiftType.lucky;
      case 'TREASURE': return GiftType.treasure;
      case 'VEHICLE': return GiftType.vehicle;
      case 'CASTLE': return GiftType.castle;
      case 'FRAME': return GiftType.frame;
      case 'AVATAR': return GiftType.avatar;
      case 'FESTIVAL': return GiftType.festival;
      default: return GiftType.static;
    }
  }

  static GiftCategory _parseGiftCategory(String category) {
    switch (category.toUpperCase()) {
      case 'HOT': return GiftCategory.hot;
      case 'BASIC': return GiftCategory.basic;
      case 'PREMIUM': return GiftCategory.premium;
      case 'LUXURY': return GiftCategory.luxury;
      case 'VIP': return GiftCategory.vip;
      case 'LUCKY': return GiftCategory.lucky;
      case 'FESTIVAL': return GiftCategory.festival;
      default: return GiftCategory.basic;
    }
  }

  // Compatible aliases for external usage
  String get name => giftName;
  double get price => coinPrice;

  bool get isHighEndGift => type == GiftType.vehicle || type == GiftType.castle || type == GiftType.svga;
  bool get isInteractiveGift => isLucky || isTreasure;
  bool get isCosmeticGift => type == GiftType.frame || type == GiftType.avatar;
}

class GiftEventModel {
  final String eventId;
  final String giftId;
  final String giftName;
  final String giftType;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final int quantity;
  final int comboMultiplier;
  final int coinCost;
  final int diamondEarned;
  final String? animationUrl;
  final String? svgaUrl;
  final String? comboAnimationUrl;
  final bool isLucky;
  final int? luckyMultiplier;
  final int? luckyWinAmount;
  final bool isTreasure;
  final int? treasurePoolCoins;
  final int? treasureDurationSeconds;
  final int? treasureMaxClaimers;
  final String? vehicleModelUrl;
  final String? castleModelUrl;
  final String? frameId;
  final String? frameImageUrl;
  final String? festivalName;
  final String? previewImageUrl;
  final int timestamp;

  GiftEventModel({
    required this.eventId,
    required this.giftId,
    required this.giftName,
    this.giftType = 'STATIC',
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    this.quantity = 1,
    this.comboMultiplier = 1,
    this.coinCost = 0,
    this.diamondEarned = 0,
    this.animationUrl,
    this.svgaUrl,
    this.comboAnimationUrl,
    this.isLucky = false,
    this.luckyMultiplier,
    this.luckyWinAmount,
    this.isTreasure = false,
    this.treasurePoolCoins,
    this.treasureDurationSeconds,
    this.treasureMaxClaimers,
    this.vehicleModelUrl,
    this.castleModelUrl,
    this.frameId,
    this.frameImageUrl,
    this.festivalName,
    this.previewImageUrl,
    this.timestamp = 0,
  });

  factory GiftEventModel.fromJson(Map<String, dynamic> json) {
    return GiftEventModel(
      eventId: json['eventId'] ?? '',
      giftId: json['giftId'] ?? '',
      giftName: json['giftName'] ?? 'Gift',
      giftType: json['giftType'] ?? 'STATIC',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'User',
      senderAvatar: json['senderAvatar'],
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? 'User',
      receiverAvatar: json['receiverAvatar'],
      quantity: json['quantity'] ?? 1,
      comboMultiplier: json['comboMultiplier'] ?? 1,
      coinCost: json['coinCost'] ?? 0,
      diamondEarned: json['diamondEarned'] ?? 0,
      animationUrl: json['animationUrl'],
      svgaUrl: json['svgaUrl'],
      comboAnimationUrl: json['comboAnimationUrl'],
      isLucky: json['isLucky'] ?? false,
      luckyMultiplier: json['luckyMultiplier'],
      luckyWinAmount: json['luckyWinAmount'],
      isTreasure: json['isTreasure'] ?? false,
      treasurePoolCoins: json['treasurePoolCoins'],
      treasureDurationSeconds: json['treasureDurationSeconds'],
      treasureMaxClaimers: json['treasureMaxClaimers'],
      vehicleModelUrl: json['vehicleModelUrl'],
      castleModelUrl: json['castleModelUrl'],
      frameId: json['frameId'],
      frameImageUrl: json['frameImageUrl'],
      festivalName: json['festivalName'],
      previewImageUrl: json['previewImageUrl'],
      timestamp: json['timestamp'] ?? 0,
    );
  }

  bool get isComboGift => comboMultiplier > 1;
  bool get isJackpot => luckyMultiplier != null && luckyMultiplier! > 1;
}

class GiftHistoryModel {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final GiftModel gift;
  final int quantity;
  final DateTime createdAt;

  GiftHistoryModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.gift,
    required this.quantity,
    required this.createdAt,
  });

  factory GiftHistoryModel.fromJson(Map<String, dynamic> json) => GiftHistoryModel(
    id: json['id'] ?? json['eventId'] ?? '',
    senderId: json['senderId'] ?? '',
    senderName: json['senderName'] ?? '',
    receiverId: json['receiverId'] ?? '',
    receiverName: json['receiverName'] ?? '',
    gift: GiftModel.fromJson(json['gift'] ?? json),
    quantity: json['quantity'] ?? 1,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
  );
}

class GiftInventoryItem {
  final String giftId;
  final String giftName;
  final int totalQuantity;
  final int totalSpent;

  GiftInventoryItem({
    required this.giftId,
    required this.giftName,
    this.totalQuantity = 0,
    this.totalSpent = 0,
  });

  factory GiftInventoryItem.fromJson(Map<String, dynamic> json) {
    return GiftInventoryItem(
      giftId: json['_id']?.toString() ?? '',
      giftName: json['giftName'] ?? '',
      totalQuantity: json['totalQuantity'] ?? 0,
      totalSpent: json['totalSpent'] ?? 0,
    );
  }
}

class GiftCollectionItem {
  final String giftId;
  final String giftName;
  final int timesUsed;
  final int uniqueReceiversCount;

  GiftCollectionItem({
    required this.giftId,
    required this.giftName,
    this.timesUsed = 0,
    this.uniqueReceiversCount = 0,
  });

  factory GiftCollectionItem.fromJson(Map<String, dynamic> json) {
    return GiftCollectionItem(
      giftId: json['giftId']?.toString() ?? '',
      giftName: json['giftName'] ?? '',
      timesUsed: json['timesUsed'] ?? 0,
      uniqueReceiversCount: json['uniqueReceiversCount'] ?? 0,
    );
  }
}

class GiftGoalModel {
  final int targetCoins;
  final int currentCoins;
  final String title;
  final double progressPercent;

  GiftGoalModel({
    this.targetCoins = 0,
    this.currentCoins = 0,
    this.title = '',
    this.progressPercent = 0.0,
  });

  factory GiftGoalModel.fromJson(Map<String, dynamic> json) {
    return GiftGoalModel(
      targetCoins: json['targetCoins'] ?? 0,
      currentCoins: json['currentCoins'] ?? 0,
      title: json['title'] ?? '',
      progressPercent: (json['progressPercent'] ?? 0).toDouble(),
    );
  }
}