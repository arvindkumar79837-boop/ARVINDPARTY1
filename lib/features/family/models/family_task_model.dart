class FamilyTaskModel {
  final String taskId;
  final String familyId;
  final String taskType;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final int rewardCoins;
  final int rewardFamilyPoints;
  final int rewardXp;
  final String status;
  final DateTime expiresAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  FamilyTaskModel({
    required this.taskId,
    required this.familyId,
    required this.taskType,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.rewardCoins,
    required this.rewardFamilyPoints,
    required this.rewardXp,
    required this.status,
    required this.expiresAt,
    this.completedAt,
    required this.createdAt,
  });

  factory FamilyTaskModel.fromJson(Map<String, dynamic> json) {
    return FamilyTaskModel(
      taskId: json['taskId'] ?? '',
      familyId: json['familyId'] ?? '',
      taskType: json['taskType'] ?? 'gift_target',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetValue: json['targetValue'] ?? 0,
      currentValue: json['currentValue'] ?? 0,
      rewardCoins: json['rewardCoins'] ?? 0,
      rewardFamilyPoints: json['rewardFamilyPoints'] ?? 0,
      rewardXp: json['rewardXp'] ?? 0,
      status: json['status'] ?? 'active',
      expiresAt: DateTime.parse(json['expiresAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'familyId': familyId,
      'taskType': taskType,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'rewardCoins': rewardCoins,
      'rewardFamilyPoints': rewardFamilyPoints,
      'rewardXp': rewardXp,
      'status': status,
      'expiresAt': expiresAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}