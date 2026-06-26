import 'package:get/get.dart';
import '../../../data/models/role_permission_model.dart';

class RoleAuthController extends GetxController {
  // करंट लॉगिन यूज़र का डेटा (प्रोटोटाइप के लिए डिफ़ॉल्ट रूप से ownerWeb रखा है)
  var currentUserRole = RoleType.ownerWeb.obs;
  var userUid = "".obs;
  var userName = "".obs;
  
  // Live permission observer
  late UserPermissions permissions;

  @override
  void onInit() {
    super.onInit();
    // Initialize default permissions
    _setupInitialPermissions();
  }

  /// Function to load role and permissions from the backend upon login
  void loginUser(RoleType role, String uid, String name, Map<String, dynamic> permissionJson, {bool is2faVerified = false}) {
    currentUserRole.value = role;
    userUid.value = uid;
    userName.value = name;
    
    // JSON डेटा को परमिशन मॉडल में पार्स करना
    permissions = UserPermissions.fromJson(permissionJson);
    
    // If the role is owner, automatically grant god-mode (all permissions)
    if (currentUserRole.value == RoleType.ownerWeb) {
      _setGodMode();
    }

    // For high-privilege roles, lock permissions until 2FA is complete
    if ([RoleType.ownerWeb, RoleType.superAdminUid, RoleType.globalManagerWeb].contains(role) && !is2faVerified) {
      permissions.is2faLocked.value = true;
    }
    
    update();
  }

  /// Secret logic to enable all powers for the owner at once
  void _setGodMode() {
    permissions = UserPermissions.godMode();
    permissions.canGenerateCoins.value = true;
    permissions.canTransferCoins.value = true;
    permissions.canApproveWithdrawals.value = true;
    permissions.canManageStaff.value = true;
    permissions.canChangeBanners.value = true;
    permissions.canGiveFramesAndEffects.value = true;
    permissions.canManageAgencies.value = true;
    permissions.canAddMiniGames.value = true;
    permissions.canBanUsers.value = true;
    permissions.canViewSecurityDashboard.value = true;
    permissions.canViewAuditLogs.value = true;
    isPasswordLocked.value = false; // Owner's password will never be locked
  }

  /// Default blueprint setup
  void _setupInitialPermissions() {
    permissions = UserPermissions(
      generateCoins: currentUserRole.value == RoleType.ownerWeb,
      transferCoins: currentUserRole.value == RoleType.ownerWeb || currentUserRole.value == RoleType.superCoinSellerUid,
      approveWithdrawals: currentUserRole.value == RoleType.ownerWeb || currentUserRole.value == RoleType.officialWeb,
      manageStaff: currentUserRole.value == RoleType.ownerWeb,
      changeBanners: false,
      giveFrames: false,
      manageAgencies: false,
      addMiniGames: currentUserRole.value == RoleType.ownerWeb,
      banUsers: false,
      viewSecurityDashboard: currentUserRole.value == RoleType.ownerWeb,
      viewAuditLogs: currentUserRole.value == RoleType.ownerWeb,
      passwordLocked: currentUserRole.value != RoleType.ownerWeb, // ओनर को छोड़कर सबका पासवर्ड लॉक
      is2faLocked: false,
    );
  }

  /// Security check before changing password
  bool attemptPasswordChange() {
    if (permissions.isPasswordLocked.value) {
      Get.snackbar(
        "Action Denied",
        "Security Alert: Your role does not allow password modification. Contact Owner.",
        snackPosition: SnackPosition.BOTTOM,
        maxWidth: 400,
      );
      return false; // Password change not allowed
    }
    return true; // Is owner, permission granted
  }

  /// Permission check tool to hide/show sidebar or any UI button
  bool hasPermission(String feature) {
    if (permissions.is2faLocked.value) return false; // Block all features if 2FA is pending
    if (currentUserRole.value == RoleType.ownerWeb) return true; // ओनर सब देख सकता है

    switch (feature) {
      case 'COIN_GEN': return permissions.canGenerateCoins.value;
      case 'COIN_TRANSFER': return permissions.canTransferCoins.value;
      case 'WITHDRAW_APPROVAL': return permissions.canApproveWithdrawals.value;
      case 'STAFF_MGT': return permissions.canManageStaff.value;
      case 'BANNER': return permissions.canChangeBanners.value;
      case 'GIVE_FRAME': return permissions.canGiveFramesAndEffects.value;
      case 'AGENCY': return permissions.canManageAgencies.value;
      case 'ADD_GAME': return permissions.canAddMiniGames.value;
      case 'BAN_USER': return permissions.canBanUsers.value;
      case 'SECURITY_DASHBOARD': return permissions.canViewSecurityDashboard.value;
      case 'AUDIT_LOGS': return permissions.canViewAuditLogs.value;
      default: return false;
    }
  }
}