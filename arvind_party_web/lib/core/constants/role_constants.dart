// ═══════════════════════════════════════════════════════════════════════════
// FILE: arvind_party_web/lib/core/constants/role_constants.dart
// ═══════════════════════════════════════════════════════════════════════════

class AppRoles {
  // TOP LEVEL
  static const String ownerWeb = 'OWNER.WEB';

  // ADMIN LEVEL
  static const String appAdminWeb = 'APP.ADMIN.WEB';
  static const String superAdminUid = 'SUPER.ADMIN.UID';
  static const String adminUid = 'ADMIN.UID';

  // MANAGEMENT LEVEL
  static const String globalManagerWeb = 'GLOBAL.MANAGER.WEB';
  static const String countryManagerWeb = 'COUNTRY.MANAGER.WEB';
  static const String bdUid = 'BD.UID';

  // COIN/AGENCY LEVEL
  static const String superCoinSellerUid = 'SUPER.COIN.SELLER.UID';
  static const String normalCoinSellerUid = 'NORMAL.COIN.SELLER.UID';

  // CUSTOMER SERVICE
  static const String csLeaderUid = 'CS.LEADER.UID';
  static const String csCustomerServiceUid = 'CS.CUSTOMER.SERVICE.UID';

  // ASSISTANTS
  static const String ownerAssistantUid = 'OWNER.ASSISTANT.UID';
  static const String adminAssistantUid = 'ADMIN.ASSISTANT.UID';
  static const String globalManagerAssistantUid =
      'GLOBAL.MANAGER.ASSISTANT.UID';

  static const List<String> allRoles = [
    ownerWeb,
    appAdminWeb,
    globalManagerWeb,
    countryManagerWeb,
    superAdminUid,
    adminUid,
    bdUid,
    superCoinSellerUid,
    normalCoinSellerUid,
    csLeaderUid,
    csCustomerServiceUid,
    ownerAssistantUid,
    adminAssistantUid,
    globalManagerAssistantUid,
  ];
}

class AppPermissions {
  static const String viewUsers = 'USER_VIEW';
  static const String editUsers = 'USER_EDIT';
  static const String banUsers = 'USER_BAN';

  static const String viewRooms = 'ROOM_VIEW';
  static const String editRooms = 'ROOM_EDIT';
  static const String closeRooms = 'ROOM_CLOSE';

  static const String viewWallet = 'WALLET_VIEW';
  static const String rechargeWallet = 'WALLET_RECHARGE';

  static const String manageEvents = 'EVENT_MANAGE';
  static const String manageReports = 'REPORT_MANAGE';

  // Yeh permission list mein nahi dikhegi, yeh sirf OWNER.WEB ke paas hogi implicitly
  static const String generateCoins = 'COIN_GENERATE';
}
