// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/models/agency_model.dart
// ARVIND PARTY - AGENCY MODEL
// ═══════════════════════════════════════════════════════════════════════════

class AgencyModel {
  final String? id;
  final String name;
  final String? ownerUid;
  final String? ownerId;
  final String? ownerName;
  final String? ownerAvatar;
  final String? logo;
  final String description;
  final List<String> hostIds;
  final int totalHosts;
  final double earnings;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AgencyModel({
    this.id,
    required this.name,
    this.ownerUid,
    this.ownerId,
    this.ownerName,
    this.ownerAvatar,
    this.logo,
    this.description = '',
    this.hostIds = const [],
    this.totalHosts = 0,
    this.earnings = 0.0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    return AgencyModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['name'] as String? ?? '',
      ownerUid: json['ownerUid'] as String?,
      ownerId: json['owner'] is Map<String, dynamic>
          ? json['owner']['_id'] as String?
          : json['owner'] as String?,
      ownerName: json['owner'] is Map<String, dynamic>
          ? json['owner']['name'] as String?
          : null,
      ownerAvatar: json['owner'] is Map<String, dynamic>
          ? json['owner']['avatar'] as String?
          : null,
      logo: json['logo'] as String?,
      description: json['description'] as String? ?? '',
      hostIds: (json['hosts'] as List<dynamic>?)
              ?.map((e) => e is Map<String, dynamic> ? e['_id'] as String : e as String)
              .toList() ??
          [],
      totalHosts: json['totalHosts'] as int? ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        'name': name,
        if (ownerUid != null) 'ownerUid': ownerUid,
        if (description.isNotEmpty) 'description': description,
        if (logo != null) 'logo': logo,
        'totalHosts': totalHosts,
        'earnings': earnings,
        'isActive': isActive,
      };

  AgencyModel copyWith({
    String? id,
    String? name,
    String? logo,
    String? description,
    double? earnings,
    int? totalHosts,
    bool? isActive,
  }) {
    return AgencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerUid: ownerUid,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerAvatar: ownerAvatar,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      hostIds: hostIds,
      totalHosts: totalHosts ?? this.totalHosts,
      earnings: earnings ?? this.earnings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class AgencyMemberModel {
  final String id;
  final String? name;
  final String? avatar;
  final String? arvindId;
  final double earnings;
  final String? role;

  AgencyMemberModel({
    required this.id,
    this.name,
    this.avatar,
    this.arvindId,
    this.earnings = 0.0,
    this.role,
  });

  factory AgencyMemberModel.fromJson(Map<String, dynamic> json) {
    return AgencyMemberModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      arvindId: json['arvindId'] as String?,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      role: json['role'] as String?,
    );
  }
}