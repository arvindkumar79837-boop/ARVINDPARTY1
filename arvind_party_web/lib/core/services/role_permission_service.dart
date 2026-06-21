// ═══════════════════════════════════════════════════════════════════════════
// SERVICE: RolePermissionService — 15+ role matrix dynamic sidebar visibility
// Controls nav visibility based on live role privileges from the backend
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class RolePermissionService extends GetxService {
  final RxString currentRole = 'assistant'.obs;
  final RxInt currentRoleLevel = 0.obs;
  final RxList<String> permissions = <String>[].obs;
  final RxBool isAuthenticated = false.obs;
  final RxBool isOwner = false.obs;
  final RxString staffId = ''.obs;
  final RxString staffUid = ''.obs;
  final RxString staffName = ''.obs;

  // ─── SIDEBAR SECTION DEFINITIONS ──────────────────────────────────
  // Each section has a permission key that gates visibility
  static final List<SidebarSection> sidebarSections = [
    SidebarSection(
      title: 'Dashboard',
      icon: 'dashboard',
      route: '/admin/dashboard',
      permissionRequired: 'dashboard.view',
    ),
    SidebarSection(
      title: 'User Management',
      icon: 'people',
      route: '/admin/users',
      permissionRequired: 'users.view',
      children: [
        SidebarItem('All Users', '/admin/users', 'users.view'),
        SidebarItem('Verify Users', '/admin/users/verify', 'users.verify'),
        SidebarItem('Banned Users', '/admin/users/banned', 'users.ban'),
      ],
    ),
    SidebarSection(
      title: 'Room Management',
      icon: 'meeting_room',
      route: '/admin/rooms',
      permissionRequired: 'rooms.view',
      children: [
        SidebarItem('Live Rooms', '/admin/rooms/live', 'rooms.view'),
        SidebarItem('All Rooms', '/admin/rooms', 'rooms.view'),
      ],
    ),
    SidebarSection(
      title: 'Wallet & Finance',
      icon: 'account_balance_wallet',
      route: '/admin/wallets',
      permissionRequired: 'wallet.view',
      children: [
        SidebarItem('Wallet Overview', '/admin/wallets', 'wallet.view'),
        SidebarItem('Withdrawals', '/admin/withdrawals', 'wallet.withdrawal_approve'),
        SidebarItem('Recharge History', '/admin/recharges', 'wallet.view'),
      ],
    ),
    SidebarSection(
      title: 'Gift Management',
      icon: 'card_giftcard',
      route: '/admin/gifts',
      permissionRequired: 'gifts.view',
    ),
    SidebarSection(
      title: 'Coin Vault',
      icon: 'monetization_on',
      route: '/admin/treasury/vault',
      permissionRequired: 'treasury.view',
      children: [
        SidebarItem('Vault Overview', '/admin/treasury/vault', 'treasury.view'),
        SidebarItem('Mint Coins', '/admin/treasury/mint', 'treasury.mint'),
        SidebarItem('Dispatch Coins', '/admin/treasury/dispatch', 'treasury.dispatch'),
        SidebarItem('Burn Coins', '/admin/treasury/burn', 'treasury.burn'),
        SidebarItem('Vault History', '/admin/treasury/vault-history', 'treasury.view'),
      ],
    ),
    SidebarSection(
      title: 'Reward Injector',
      icon: 'auto_awesome',
      route: '/admin/rewards',
      permissionRequired: 'rewards.inject',
    ),
    SidebarSection(
      title: 'Streamer Targets',
      icon: 'track_changes',
      route: '/admin/targets',
      permissionRequired: 'targets.view',
      children: [
        SidebarItem('All Targets', '/admin/targets', 'targets.view'),
        SidebarItem('Create Target', '/admin/targets/create', 'targets.create'),
        SidebarItem('Pending Exchanges', '/admin/targets/exchanges', 'targets.approve_exchange'),
        SidebarItem('Auto Cycle', '/admin/targets/auto-cycle', 'targets.auto_cycle'),
      ],
    ),
    SidebarSection(
      title: 'Agency Management',
      icon: 'business',
      route: '/admin/agencies',
      permissionRequired: 'agency.view',
      children: [
        SidebarItem('All Agencies', '/admin/agencies', 'agency.view'),
        SidebarItem('Commission Tiers', '/admin/agencies/commission', 'commission.view'),
      ],
    ),
    SidebarSection(
      title: 'Family Management',
      icon: 'group',
      route: '/admin/families',
      permissionRequired: 'family.view',
    ),
    SidebarSection(
      title: 'Events',
      icon: 'event',
      route: '/admin/events',
      permissionRequired: 'events.view',
    ),
    SidebarSection(
      title: 'VIP Management',
      icon: 'stars',
      route: '/admin/vip',
      permissionRequired: 'vip.view',
    ),
    SidebarSection(
      title: 'Support Tickets',
      icon: 'support_agent',
      route: '/admin/support',
      permissionRequired: 'support.view',
    ),
    SidebarSection(
      title: 'Reports & Moderation',
      icon: 'flag',
      route: '/admin/reports',
      permissionRequired: 'reports.view',
    ),
    SidebarSection(
      title: 'Notifications',
      icon: 'notifications',
      route: '/admin/notifications',
      permissionRequired: 'notifications.send',
    ),
    SidebarSection(
      title: 'Staff Management',
      icon: 'admin_panel_settings',
      route: '/admin/staff',
      permissionRequired: 'staff.view',
      children: [
        SidebarItem('Staff List', '/admin/staff/list', 'staff.view'),
        SidebarItem('Create Staff', '/admin/staff/create', 'staff.create'),
        SidebarItem('Role Hierarchy', '/admin/staff/roles', 'staff.view'),
      ],
    ),
    SidebarSection(
      title: 'Settings',
      icon: 'settings',
      route: '/admin/settings',
      permissionRequired: 'settings.view',
    ),
    SidebarSection(
      title: 'Audit Logs',
      icon: 'history',
      route: '/admin/audit-logs',
      permissionRequired: 'audit.view',
    ),
    SidebarSection(
      title: 'Announcements',
      icon: 'campaign',
      route: '/admin/announcements',
      permissionRequired: 'announcements.send',
    ),
    SidebarSection(
      title: 'Leaderboard',
      icon: 'leaderboard',
      route: '/admin/leaderboard',
      permissionRequired: 'leaderboard.view',
    ),
    SidebarSection(
      title: 'Coin Orders',
      icon: 'receipt_long',
      route: '/admin/coin-orders',
      permissionRequired: 'coin_orders.view',
    ),
    SidebarSection(
      title: 'Security',
      icon: 'security',
      route: '/admin/security',
      permissionRequired: 'security.view',
    ),
  ];

  /// Returns only the sidebar sections this role can see
  List<SidebarSection> get visibleSections {
    return sidebarSections.where((section) {
      if (isOwner.value) return true;
      if (permissions.contains(section.permissionRequired)) return true;
      if (section.children != null) {
        return section.children!.any((child) => permissions.contains(child.permissionRequired));
      }
      return false;
    }).toList();
  }

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    if (isOwner.value) return true;
    return permissions.contains(permission);
  }

  /// Check if user has any of the given permissions
  bool hasAnyPermission(List<String> permissionList) {
    if (isOwner.value) return true;
    return permissionList.any((p) => permissions.contains(p));
  }

  /// Check if user has all of the given permissions
  bool hasAllPermissions(List<String> permissionList) {
    if (isOwner.value) return true;
    return permissionList.every((p) => permissions.contains(p));
  }

  /// Get the label for the current role
  String get currentRoleLabel {
    const labels = {
      'owner': 'Owner',
      'super_admin': 'Super Admin',
      'admin': 'Admin',
      'global_manager': 'Global Manager',
      'country_manager': 'Country Manager',
      'bd_staff': 'BD Staff',
      'super_coin_seller': 'Super Coin Seller',
      'normal_coin_seller': 'Normal Coin Seller',
      'customer_service_manager': 'CS Manager',
      'customer_service_senior': 'Senior CS',
      'customer_service': 'Customer Service',
      'assistant_manager': 'Assistant Manager',
      'assistant_senior': 'Senior Assistant',
      'assistant': 'Assistant',
      'moderator': 'Moderator',
    };
    return labels[currentRole.value] ?? currentRole.value;
  }

  /// Initialize from staff login response
  void initFromStaff(Map<String, dynamic> staffData) {
    currentRole.value = staffData['role'] ?? 'assistant';
    currentRoleLevel.value = staffData['roleLevel'] ?? 0;
    permissions.value = List<String>.from(staffData['permissions'] ?? []);
    isAuthenticated.value = true;
    isOwner.value = staffData['role'] == 'owner';
    staffId.value = staffData['_id'] ?? '';
    staffUid.value = staffData['uid'] ?? '';
    staffName.value = staffData['name'] ?? staffData['loginId'] ?? '';
  }

  void logout() {
    currentRole.value = 'assistant';
    currentRoleLevel.value = 0;
    permissions.clear();
    isAuthenticated.value = false;
    isOwner.value = false;
    staffId.value = '';
    staffUid.value = '';
    staffName.value = '';
  }
}

class SidebarSection {
  final String title;
  final String icon;
  final String route;
  final String permissionRequired;
  final List<SidebarItem>? children;

  SidebarSection({
    required this.title,
    required this.icon,
    required this.route,
    required this.permissionRequired,
    this.children,
  });
}

class SidebarItem {
  final String title;
  final String route;
  final String permissionRequired;

  SidebarItem(this.title, this.route, this.permissionRequired);
}