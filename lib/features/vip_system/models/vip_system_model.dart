import 'package:flutter/material.dart';

/// ============================================================
/// ARVIND PARTY - VIP SYSTEM MODEL
/// Complete VIP 1-15, SVIP, Premium, Cosmetics, Missions Model
/// ============================================================

class VipSystemStatus {
  final String userUid;
  final int vipLevel;
  final int vipXp;
  final int vipXpToNextLevel;
  final int vipLevelProgress;
  final bool isSvip;
  final int svipLevel;
  final Map<String, dynamic>? svipConfig;
  final bool isPremium;
  final DateTime? premiumExpiry;
  final int premiumDaysRemaining;
  final ActiveCosmetics activeCosmetics;
  final List<UnlockedFrame> unlockedFrames;
  final List<UnlockedEntranceCar> unlockedEntranceCars;
  final List<UnlockedNameColor> unlockedNameColors;
  final List<UnlockedChatBubble> unlockedChatBubbles;
  final List<UnlockedBadge> unlockedBadges;
  final List<VipMission> vipMissions;
  final double totalRechargeAmount;
  final double totalGiftReceivedValue;
  final double totalGiftSentValue;
  final bool vipGlobalAlertsEnabled;
  final List<XpHistoryEntry> xpHistory;

  VipSystemStatus({
    required this.userUid,
    this.vipLevel = 0,
    this.vipXp = 0,
    this.vipXpToNextLevel = 1000,
    this.vipLevelProgress = 0,
    this.isSvip = false,
    this.svipLevel = 0,
    this.svipConfig,
    this.isPremium = false,
    this.premiumExpiry,
    this.premiumDaysRemaining = 0,
    ActiveCosmetics? activeCosmetics,
    this.unlockedFrames = const [],
    this.unlockedEntranceCars = const [],
    this.unlockedNameColors = const [],
    this.unlockedChatBubbles = const [],
    this.unlockedBadges = const [],
    this.vipMissions = const [],
    this.totalRechargeAmount = 0,
    this.totalGiftReceivedValue = 0,
    this.totalGiftSentValue = 0,
    this.vipGlobalAlertsEnabled = true,
    this.xpHistory = const [],
  }) : activeCosmetics = activeCosmetics ?? ActiveCosmetics();

  factory VipSystemStatus.fromJson(Map<String, dynamic> json) {
    return VipSystemStatus(
      userUid: json['user_uid'] ?? '',
      vipLevel: json['vip_level'] ?? 0,
      vipXp: json['vip_xp'] ?? 0,
      vipXpToNextLevel: json['vip_xp_to_next_level'] ?? 1000,
      vipLevelProgress: json['vip_level_progress'] ?? 0,
      isSvip: json['is_svip'] ?? false,
      svipLevel: json['svip_level'] ?? 0,
      svipConfig: json['svip_config'] as Map<String, dynamic>?,
      isPremium: json['is_premium'] ?? false,
      premiumExpiry: json['premium_expiry'] != null ? DateTime.tryParse(json['premium_expiry']) : null,
      premiumDaysRemaining: json['premium_days_remaining'] ?? 0,
      activeCosmetics: ActiveCosmetics.fromJson(json['active_cosmetics'] ?? {}),
      unlockedFrames: (json['unlocked_frames'] as List<dynamic>?)
          ?.map((e) => UnlockedFrame.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      unlockedEntranceCars: (json['unlocked_entrance_cars'] as List<dynamic>?)
          ?.map((e) => UnlockedEntranceCar.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      unlockedNameColors: (json['unlocked_name_colors'] as List<dynamic>?)
          ?.map((e) => UnlockedNameColor.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      unlockedChatBubbles: (json['unlocked_chat_bubbles'] as List<dynamic>?)
          ?.map((e) => UnlockedChatBubble.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      unlockedBadges: (json['unlocked_badges'] as List<dynamic>?)
          ?.map((e) => UnlockedBadge.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      vipMissions: (json['vip_missions'] as List<dynamic>?)
          ?.map((e) => VipMission.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalRechargeAmount: (json['total_recharge_amount'] ?? 0).toDouble(),
      totalGiftReceivedValue: (json['total_gift_received_value'] ?? 0).toDouble(),
      totalGiftSentValue: (json['total_gift_sent_value'] ?? 0).toDouble(),
      vipGlobalAlertsEnabled: json['vip_global_alerts_enabled'] ?? true,
      xpHistory: (json['xp_history'] as List<dynamic>?)
          ?.map((e) => XpHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class ActiveCosmetics {
  final String frameId;
  final String entranceCarId;
  final String nameColor;
  final String chatBubbleId;
  final String badgeId;

  ActiveCosmetics({
    this.frameId = '',
    this.entranceCarId = '',
    this.nameColor = '#FFFFFF',
    this.chatBubbleId = '',
    this.badgeId = '',
  });

  factory ActiveCosmetics.fromJson(Map<String, dynamic> json) {
    return ActiveCosmetics(
      frameId: json['frame_id'] ?? '',
      entranceCarId: json['entrance_car_id'] ?? '',
      nameColor: json['name_color'] ?? '#FFFFFF',
      chatBubbleId: json['chat_bubble_id'] ?? '',
      badgeId: json['badge_id'] ?? '',
    );
  }

  Color get displayNameColor {
    if (nameColor.isEmpty || nameColor == '#FFFFFF') return Colors.white;
    final hex = nameColor.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.white;
  }

  Map<String, dynamic> toJson() => {
    'frame_id': frameId,
    'entrance_car_id': entranceCarId,
    'name_color': nameColor,
    'chat_bubble_id': chatBubbleId,
    'badge_id': badgeId,
  };
}

class UnlockedFrame {
  final String frameId;
  final String frameName;
  final String frameUrl;
  final DateTime unlockedAt;
  final bool isAnimated;

  UnlockedFrame({
    required this.frameId,
    required this.frameName,
    this.frameUrl = '',
    DateTime? unlockedAt,
    this.isAnimated = false,
  }) : unlockedAt = unlockedAt ?? DateTime.now();

  factory UnlockedFrame.fromJson(Map<String, dynamic> json) {
    return UnlockedFrame(
      frameId: json['frame_id'] ?? '',
      frameName: json['frame_name'] ?? '',
      frameUrl: json['frame_url'] ?? '',
      unlockedAt: json['unlocked_at'] != null ? DateTime.tryParse(json['unlocked_at']) : DateTime.now(),
      isAnimated: json['is_animated'] ?? false,
    );
  }
}

class UnlockedEntranceCar {
  final String carId;
  final String carName;
  final String carAnimationUrl;
  final DateTime unlockedAt;
  final int animationDurationMs;

  UnlockedEntranceCar({
    required this.carId,
    required this.carName,
    this.carAnimationUrl = '',
    DateTime? unlockedAt,
    this.animationDurationMs = 3000,
  }) : unlockedAt = unlockedAt ?? DateTime.now();

  factory UnlockedEntranceCar.fromJson(Map<String, dynamic> json) {
    return UnlockedEntranceCar(
      carId: json['car_id'] ?? '',
      carName: json['car_name'] ?? '',
      carAnimationUrl: json['car_animation_url'] ?? '',
      unlockedAt: json['unlocked_at'] != null ? DateTime.tryParse(json['unlocked_at']) : DateTime.now(),
      animationDurationMs: json['animation_duration_ms'] ?? 3000,
    );
  }
}

class UnlockedNameColor {
  final String colorId;
  final String colorName;
  final String hexCode;
  final bool isGradient;
  final List<String> gradientColors;
  final DateTime unlockedAt;

  UnlockedNameColor({
    required this.colorId,
    required this.colorName,
    this.hexCode = '#FFFFFF',
    this.isGradient = false,
    this.gradientColors = const [],
    DateTime? unlockedAt,
  }) : unlockedAt = unlockedAt ?? DateTime.now();

  Color get displayColor {
    final hex = hexCode.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.white;
  }

  factory UnlockedNameColor.fromJson(Map<String, dynamic> json) {
    return UnlockedNameColor(
      colorId: json['color_id'] ?? '',
      colorName: json['color_name'] ?? '',
      hexCode: json['hex_code'] ?? '#FFFFFF',
      isGradient: json['is_gradient'] ?? false,
      gradientColors: (json['gradient_colors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      unlockedAt: json['unlocked_at'] != null ? DateTime.tryParse(json['unlocked_at']) : DateTime.now(),
    );
  }
}

class UnlockedChatBubble {
  final String bubbleId;
  final String bubbleName;
  final String bubbleUrl;
  final DateTime unlockedAt;
  final bool isAnimated;

  UnlockedChatBubble({
    required this.bubbleId,
    required this.bubbleName,
    this.bubbleUrl = '',
    DateTime? unlockedAt,
    this.isAnimated = false,
  }) : unlockedAt = unlockedAt ?? DateTime.now();

  factory UnlockedChatBubble.fromJson(Map<String, dynamic> json) {
    return UnlockedChatBubble(
      bubbleId: json['bubble_id'] ?? '',
      bubbleName: json['bubble_name'] ?? '',
      bubbleUrl: json['bubble_url'] ?? '',
      unlockedAt: json['unlocked_at'] != null ? DateTime.tryParse(json['unlocked_at']) : DateTime.now(),
      isAnimated: json['is_animated'] ?? false,
    );
  }
}

class UnlockedBadge {
  final String badgeId;
  final String badgeName;
  final String badgeUrl;
  final DateTime unlockedAt;

  UnlockedBadge({
    required this.badgeId,
    required this.badgeName,
    this.badgeUrl = '',
    DateTime? unlockedAt,
  }) : unlockedAt = unlockedAt ?? DateTime.now();

  factory UnlockedBadge.fromJson(Map<String, dynamic> json) {
    return UnlockedBadge(
      badgeId: json['badge_id'] ?? '',
      badgeName: json['badge_name'] ?? '',
      badgeUrl: json['badge_url'] ?? '',
      unlockedAt: json['unlocked_at'] != null ? DateTime.tryParse(json['unlocked_at']) : DateTime.now(),
    );
  }
}

class VipMission {
  final String missionId;
  final String missionName;
  final String missionType;
  final double targetValue;
  final double currentProgress;
  final bool isCompleted;
  final bool rewardClaimed;
  final String rewardType;
  final double rewardValue;
  final DateTime? expiresAt;
  final DateTime startedAt;
  final DateTime? completedAt;

  VipMission({
    required this.missionId,
    required this.missionName,
    this.missionType = 'daily',
    this.targetValue = 0,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.rewardClaimed = false,
    this.rewardType = 'coins',
    this.rewardValue = 0,
    this.expiresAt,
    DateTime? startedAt,
    this.completedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  double get progressPercent =>
      targetValue > 0 ? (currentProgress / targetValue).clamp(0.0, 1.0) : 0.0;

  String get timeRemainingText {
    if (expiresAt == null) return 'No expiry';
    final diff = expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return '${diff.inSeconds}s';
  }

  IconData get missionIcon {
    switch (missionType) {
      case 'recharge': return Icons.account_balance_wallet;
      case 'gift': return Icons.card_giftcard;
      case 'gaming': return Icons.sports_esports;
      case 'social': return Icons.chat;
      case 'daily': return Icons.calendar_today;
      case 'special': return Icons.star;
      default: return Icons.flag;
    }
  }

  Color get missionColor {
    switch (missionType) {
      case 'recharge': return Colors.orange;
      case 'gift': return Colors.pink;
      case 'gaming': return Colors.blue;
      case 'social': return Colors.green;
      case 'daily': return Colors.purple;
      case 'special': return Colors.amber;
      default: return Colors.grey;
    }
  }

  factory VipMission.fromJson(Map<String, dynamic> json) {
    return VipMission(
      missionId: json['mission_id'] ?? '',
      missionName: json['mission_name'] ?? '',
      missionType: json['mission_type'] ?? 'daily',
      targetValue: (json['target_value'] ?? 0).toDouble(),
      currentProgress: (json['current_progress'] ?? 0).toDouble(),
      isCompleted: json['is_completed'] ?? false,
      rewardClaimed: json['reward_claimed'] ?? false,
      rewardType: json['reward_type'] ?? 'coins',
      rewardValue: (json['reward_value'] ?? 0).toDouble(),
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at']) : null,
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at']) ?? DateTime.now() : DateTime.now(),
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
    );
  }
}

class CosmeticShopItem {
  final String itemId;
  final String itemType;
  final String itemName;
  final String description;
  final String imageUrl;
  final String animationUrl;
  final int animationDurationMs;
  final double coinCost;
  final int vipLevelRequired;
  final int svipLevelRequired;
  final bool isPremiumExclusive;
  final bool isSvipExclusive;
  final bool isAnimated;
  final bool isGradient;
  final String hexCode;
  final List<String> gradientColors;
  final String rarity;
  final bool isActive;
  final bool isLimitedEdition;
  final int limitedEditionQuantity;
  final int limitedEditionSold;
  final int displayOrder;
  final bool canAccess;
  final bool isOwned;
  final bool meetsVipReq;
  final bool meetsSvipReq;
  final bool hasPremium;
  final bool hasSvip;

  CosmeticShopItem({
    required this.itemId,
    required this.itemType,
    required this.itemName,
    this.description = '',
    this.imageUrl = '',
    this.animationUrl = '',
    this.animationDurationMs = 3000,
    this.coinCost = 0,
    this.vipLevelRequired = 0,
    this.svipLevelRequired = 0,
    this.isPremiumExclusive = false,
    this.isSvipExclusive = false,
    this.isAnimated = false,
    this.isGradient = false,
    this.hexCode = '#FFFFFF',
    this.gradientColors = const [],
    this.rarity = 'common',
    this.isActive = true,
    this.isLimitedEdition = false,
    this.limitedEditionQuantity = 0,
    this.limitedEditionSold = 0,
    this.displayOrder = 0,
    this.canAccess = false,
    this.isOwned = false,
    this.meetsVipReq = false,
    this.meetsSvipReq = false,
    this.hasPremium = false,
    this.hasSvip = false,
  });

  Color get displayColor {
    if (hexCode.isEmpty || hexCode == '#FFFFFF') return Colors.white;
    final hex = hexCode.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.white;
  }

  Color get rarityColor {
    switch (rarity) {
      case 'common': return Colors.grey;
      case 'rare': return Colors.blue;
      case 'epic': return Colors.purple;
      case 'legendary': return Colors.orange;
      case 'godly': return const Color(0xFFFF1493);
      default: return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (itemType) {
      case 'frame': return Icons.crop_original;
      case 'entrance_car': return Icons.directions_car;
      case 'name_color': return Icons.palette;
      case 'chat_bubble': return Icons.chat_bubble;
      case 'badge': return Icons.verified;
      case 'emote': return Icons.emoji_emotions;
      case 'gift': return Icons.card_giftcard;
      default: return Icons.shopping_bag;
    }
  }

  factory CosmeticShopItem.fromJson(Map<String, dynamic> json) {
    return CosmeticShopItem(
      itemId: json['item_id'] ?? '',
      itemType: json['item_type'] ?? 'frame',
      itemName: json['item_name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      animationUrl: json['animation_url'] ?? '',
      animationDurationMs: json['animation_duration_ms'] ?? 3000,
      coinCost: (json['coin_cost'] ?? 0).toDouble(),
      vipLevelRequired: json['vip_level_required'] ?? 0,
      svipLevelRequired: json['svip_level_required'] ?? 0,
      isPremiumExclusive: json['is_premium_exclusive'] ?? false,
      isSvipExclusive: json['is_svip_exclusive'] ?? false,
      isAnimated: json['is_animated'] ?? false,
      isGradient: json['is_gradient'] ?? false,
      hexCode: json['hex_code'] ?? '#FFFFFF',
      gradientColors: (json['gradient_colors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      rarity: json['rarity'] ?? 'common',
      isActive: json['is_active'] ?? true,
      isLimitedEdition: json['is_limited_edition'] ?? false,
      limitedEditionQuantity: json['limited_edition_quantity'] ?? 0,
      limitedEditionSold: json['limited_edition_sold'] ?? 0,
      displayOrder: json['display_order'] ?? 0,
      canAccess: json['can_access'] ?? false,
      isOwned: json['is_owned'] ?? false,
      meetsVipReq: json['meets_vip_req'] ?? false,
      meetsSvipReq: json['meets_svip_req'] ?? false,
      hasPremium: json['has_premium'] ?? false,
      hasSvip: json['has_svip'] ?? false,
    );
  }
}

class XpHistoryEntry {
  final double amount;
  final String source;
  final int previousLevel;
  final int newLevel;
  final String description;
  final DateTime createdAt;

  XpHistoryEntry({
    required this.amount,
    this.source = 'bonus',
    this.previousLevel = 0,
    this.newLevel = 0,
    this.description = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  IconData get sourceIcon {
    switch (source) {
      case 'recharge': return Icons.account_balance_wallet;
      case 'gift_sent': return Icons.send;
      case 'gift_received': return Icons.card_giftcard;
      case 'mission': return Icons.flag;
      case 'bonus': return Icons.star;
      case 'admin': return Icons.admin_panel_settings;
      default: return Icons.add_circle;
    }
  }

  factory XpHistoryEntry.fromJson(Map<String, dynamic> json) {
    return XpHistoryEntry(
      amount: (json['amount'] ?? 0).toDouble(),
      source: json['source'] ?? 'bonus',
      previousLevel: json['previous_level'] ?? 0,
      newLevel: json['new_level'] ?? 0,
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) ?? DateTime.now() : DateTime.now(),
    );
  }
}

/// VIP Level display helper
class VipLevelHelper {
  static const Map<int, String> levelNames = {
    1: 'Bronze',
    2: 'Silver',
    3: 'Silver Elite',
    4: 'Gold',
    5: 'Gold Elite',
    6: 'Platinum',
    7: 'Platinum Elite',
    8: 'Diamond',
    9: 'Diamond Elite',
    10: 'Crown',
    11: 'Crown Elite',
    12: 'Emperor',
    13: 'Emperor Elite',
    14: 'Legend',
    15: 'GOD',
  };

  static const Map<int, Color> levelColors = {
    1: Color(0xFFCD7F32),
    2: Color(0xFFC0C0C0),
    3: Color(0xFFE8E8E8),
    4: Color(0xFFFFD700),
    5: Color(0xFFFFC107),
    6: Color(0xFFE5E4E2),
    7: Color(0xFFB0C4DE),
    8: Color(0xFF00CED1),
    9: Color(0xFF4169E1),
    10: Color(0xFFFFD700),
    11: Color(0xFFFF8C00),
    12: Color(0xFF8B0000),
    13: Color(0xFF4B0082),
    14: Color(0xFFFF1493),
    15: Color(0xFFFF4500),
  };

  static String getName(int level) => levelNames[level] ?? 'Unknown';
  static Color getColor(int level) => levelColors[level] ?? Colors.grey;

  static const Map<int, String> svipNames = {
    1: 'SVIP Silver',
    2: 'SVIP Gold',
    3: 'SVIP Platinum',
    4: 'SVIP Diamond',
    5: 'SVIP GOD',
  };

  static const Map<int, Color> svipColors = {
    1: Color(0xFFFFD700),
    2: Color(0xFFFF4500),
    3: Color(0xFF8A2BE2),
    4: Color(0xFF00CED1),
    5: Color(0xFFFF1493),
  };

  static String getSvipName(int level) => svipNames[level] ?? 'SVIP';
  static Color getSvipColor(int level) => svipColors[level] ?? Colors.amber;
}