class FamilyInvitationModel {
  final String invitationId;
  final String familyId;
  final String familyName;
  final String familyBadge;
  final String senderUid;
  final String senderName;
  final String receiverUid;
  final String status;
  final String? message;
  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final DateTime? createdAt;

  FamilyInvitationModel({
    required this.invitationId,
    required this.familyId,
    required this.familyName,
    required this.familyBadge,
    required this.senderUid,
    required this.senderName,
    required this.receiverUid,
    required this.status,
    this.message,
    this.expiresAt,
    this.respondedAt,
    this.createdAt,
  });

  factory FamilyInvitationModel.fromJson(Map<String, dynamic> json) {
    return FamilyInvitationModel(
      invitationId: json['invitation_id'] ?? '',
      familyId: json['familyId'] ?? '',
      familyName: json['family_name'] ?? '',
      familyBadge: json['family_badge'] ?? 'TEAM_ARVIND',
      senderUid: json['sender_uid'] ?? '',
      senderName: json['sender_name'] ?? '',
      receiverUid: json['receiver_uid'] ?? '',
      status: json['status'] ?? 'pending',
      message: json['message'],
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invitation_id': invitationId,
      'familyId': familyId,
      'family_name': familyName,
      'family_badge': familyBadge,
      'sender_uid': senderUid,
      'sender_name': senderName,
      'receiver_uid': receiverUid,
      'status': status,
      'message': message,
      'expiresAt': expiresAt?.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
}