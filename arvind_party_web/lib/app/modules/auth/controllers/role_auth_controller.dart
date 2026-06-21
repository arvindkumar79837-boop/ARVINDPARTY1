import 'package:get/get.dart';
import '../../../data/models/role_permission_model.dart'; // अपने मॉडल का सही पाथ दें

class RoleAuthController extends GetxController {
  // करंट लॉगिन यूज़र का डेटा (प्रोटोटाइप के लिए डिफ़ॉल्ट रूप से ownerWeb रखा है)
  var currentUserRole = RoleType.ownerWeb.obs;
  var userUid = "".obs;
  var userName = "".obs;
  
  // लाइव परमिशन ऑब्जर्वर
  late UserPermissions permissions;

  @override
  void onInit() {
    super.onInit();
    // डिफ़ॉल्ट परमिशंस इनिशियलाइज़ कर रहे हैं
    _setupInitialPermissions();
  }

  /// लॉगिन के समय बैकएंड से मिले रोल और परमिशन को लोड करने का फंक्शन
  void loginUser(RoleType role, String uid, String name, Map<String, dynamic> permissionJson) {
    currentUserRole.value = role;
    userUid.value = uid;
    userName.value = name;
    
    // JSON डेटा को परमिशन मॉडल में पार्स करना
    permissions = UserPermissions.fromJson(permissionJson);
    
    // अगर रोल ओनर है, तो उसे गॉड-मोड (सारी परमिशंस) ऑटोमैटिक दे दो
    if (currentUserRole.value == RoleType.ownerWeb) {
      _setGodMode();
    }
    
    update();
  }

  /// ओनर के लिए सारे पावर एक साथ ऑन करने का सीक्रेट लॉजिक
  void _setGodMode() {
    permissions.canGenerateCoins.value = true;
    permissions.canTransferCoins.value = true;
    permissions.canApproveWithdrawals.value = true;
    permissions.canManageStaff.value = true;
    permissions.canChangeBanners.value = true;
    permissions.canGiveFramesAndEffects.value = true;
    permissions.canManageAgencies.value = true;
    permissions.canAddMiniGames.value = true;
    permissions.canBanUsers.value = true;
    permissions.isPasswordLocked.value = false; // ओनर का पासवर्ड कभी लॉक नहीं होगा
  }

  /// डिफ़ॉल्ट ब्लूप्रिंट सेटअप
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
      passwordLocked: currentUserRole.value != RoleType.ownerWeb, // ओनर को छोड़कर सबका पासवर्ड लॉक
    );
  }

  /// पासवर्ड चेंज करने से पहले सिक्योरिटी चेक
  bool attemptPasswordChange() {
    if (permissions.isPasswordLocked.value) {
      Get.snackbar(
        "Action Denied",
        "Security Alert: Your role does not allow password modification. Contact Owner.",
        snackPosition: SnackPosition.BOTTOM,
        maxWidth: 400,
      );
      return false; // पासवर्ड बदलने की अनुमति नहीं है
    }
    return true; // ओनर है, अनुमति है
  }

  /// साइडबार या किसी यूआई बटन को हाइड/शो करने के लिए परमिशन चेक टूल
  bool hasPermission(String feature) {
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
      default: return false;
    }
  }
}