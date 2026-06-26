class FamilyLeaderboardEntry {
  final String uid;
  final String username;
  final String avatar;
  final int totalContribution;
  final int totalCoinsGifted;
  final int totalXPEarned;
  final int rank;
  final String period;

  FamilyLeaderboardEntry({
    required this.uid,
    required this.username,
    this.avatar = '',
    this.totalContribution = 0,
    this.totalCoinsGifted = 0,
    this.totalXPEarned = 0,
    this.rank = 0,
    this.period = 'all_time',
  });

  factory FamilyLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return FamilyLeaderboardEntry(
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      totalContribution: json['totalContribution'] ?? 0,
      totalCoinsGifted: json['totalCoinsGifted'] ?? 0,
      totalXPEarned: json['totalXPEarned'] ?? 0,
      rank: json['rank'] ?? 0,
      period: json['period'] ?? 'all_time',
    );
  }
}

class FamilyStayRewardSession {
  final String? sessionId;
  final bool active;
  final int durationMinutes;
  final int totalCoinsEarned;
  final int totalXpEarned;
  final bool canRedeem;
  final int remainingMs;

  FamilyStayRewardSession({
    this.sessionId,
    this.active = false,
    this.durationMinutes = 0,
    this.totalCoinsEarned = 0,
    this.totalXpEarned = 0,
    this.canRedeem = false,
    this.remainingMs = 0,
  });

  factory FamilyStayRewardSession.fromJson(Map<String, dynamic> json) {
    return FamilyStayRewardSession(
      sessionId: json['sessionId']?.toString(),
      active: json['active'] ?? false,
      durationMinutes: json['durationMinutes'] ?? 0,
      totalCoinsEarned: json['totalCoinsEarned'] ?? 0,
      totalXpEarned: json['totalXpEarned'] ?? 0,
      canRedeem: json['canRedeem'] ?? false,
      remainingMs: json['remainingMs'] ?? 0,
    );
  }
}