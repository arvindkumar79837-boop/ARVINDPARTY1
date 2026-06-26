class FamilyModel {
  final String familyId;
  final String familyName;
  final String familyBadge;
  final String? familySlogan;
  final String? familyIntro;
  final String? familyLogo;
  final String creatorUid;
  final int currentLevel;
  final int totalXp;
  final List<String> membersList;
  final int memberCount;
  final int maxMembers;
  final int maxAdminSlots;
  final List<Map<String, dynamic>> adminsList;
  final int familyPoints;
  final int totalWealth;
  final int totalGiftsSent;
  final int treasuryCoins;
  final List<String> unlockedPowers;
  final String? officialRoomId;
  final bool isActive;
  final bool isBanned;
  final String? announcement;
  final Map<String, dynamic> rewardConfig;
  final DateTime? createdAt;

  FamilyModel({
    required this.familyId,
    required this.familyName,
    required this.familyBadge,
    this.familySlogan,
    this.familyIntro,
    this.familyLogo,
    required this.creatorUid,
    required this.currentLevel,
    required this.totalXp,
    required this.membersList,
    required this.memberCount,
    required this.maxMembers,
    this.maxAdminSlots = 5,
    this.adminsList = const [],
    required this.familyPoints,
    required this.totalWealth,
    required this.totalGiftsSent,
    required this.treasuryCoins,
    required this.unlockedPowers,
    this.officialRoomId,
    required this.isActive,
    required this.isBanned,
    this.announcement,
    this.rewardConfig = const {},
    this.createdAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      familyId: json['familyId'] ?? json['family_id'] ?? '',
      familyName: json['family_name'] ?? '',
      familyBadge: json['family_badge'] ?? 'TEAM_ARVIND',
      familySlogan: json['family_slogan'],
      familyIntro: json['family_intro'],
      familyLogo: json['family_logo'],
      creatorUid: json['creator_uid'] ?? '',
      currentLevel: json['current_level'] ?? 1,
      totalXp: json['total_xp'] ?? 0,
      membersList: List<String>.from(json['members_list'] ?? []),
      memberCount: json['memberCount'] ?? json['member_count'] ?? 0,
      maxMembers: json['member_limit'] ?? json['max_members'] ?? 20,
      maxAdminSlots: json['maxAdminSlots'] ?? json['max_admin_slots'] ?? 5,
      adminsList: List<Map<String, dynamic>>.from(json['admins_list'] ?? []),
      familyPoints: json['family_points'] ?? 0,
      totalWealth: json['total_wealth'] ?? json['totalWealth'] ?? 0,
      totalGiftsSent: json['total_gifts_sent'] ?? 0,
      treasuryCoins: json['treasuryCoins'] ?? 0,
      unlockedPowers: List<String>.from(json['unlocked_powers'] ?? []),
      officialRoomId: json['official_room_id'],
      isActive: json['is_active'] ?? true,
      isBanned: json['is_banned'] ?? false,
      announcement: json['announcement'],
      rewardConfig: Map<String, dynamic>.from(json['reward_config'] ?? {}),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'familyId': familyId,
      'family_name': familyName,
      'family_badge': familyBadge,
      'family_slogan': familySlogan,
      'family_intro': familyIntro,
      'family_logo': familyLogo,
      'creator_uid': creatorUid,
      'current_level': currentLevel,
      'total_xp': totalXp,
      'members_list': membersList,
      'memberCount': memberCount,
      'member_limit': maxMembers,
      'max_admin_slots': maxAdminSlots,
      'admins_list': adminsList,
      'family_points': familyPoints,
      'total_wealth': totalWealth,
      'total_gifts_sent': totalGiftsSent,
      'treasuryCoins': treasuryCoins,
      'unlocked_powers': unlockedPowers,
      'official_room_id': officialRoomId,
      'is_active': isActive,
      'is_banned': isBanned,
      'announcement': announcement,
      'reward_config': rewardConfig,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}