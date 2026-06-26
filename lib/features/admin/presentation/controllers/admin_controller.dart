import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';

class AdminController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var totalUsers = 0.obs;
  var activeUsers = 0.obs;
  var blockedUsers = 0.obs;
  var bannedUsers = 0.obs;
  var totalStaff = 0.obs;
  var totalBroadcasts = 0.obs;

  var users = <Map<String, dynamic>>[].obs;
  var filteredUsers = <Map<String, dynamic>>[].obs;
  var staffMembers = <Map<String, dynamic>>[].obs;
  var broadcasts = <Map<String, dynamic>>[].obs;
  var withdrawals = <Map<String, dynamic>>[].obs;

  var selectedUserId = Rxn<String>();
  var selectedStaffId = Rxn<String>();

  var usersPage = 1.obs;
  var usersPerPage = 10.obs;

  var searchQuery = ''.obs;
  var statusFilter = 'all'.obs;

  var walletUserId = ''.obs;
  var walletAmount = ''.obs;
  var walletType = 'coins'.obs;
  var walletAction = 'add'.obs;

  var staffName = ''.obs;
  var staffEmail = ''.obs;
  var staffPhone = ''.obs;
  var staffRole = ''.obs;
  var staffPermissions = <String>[].obs;
  var availableRoles = <Map<String, dynamic>>[].obs;
  var allPermissions = <String>[].obs;
  var roleHierarchy = <String, dynamic>{}.obs;

  var broadcastTitle = ''.obs;
  var broadcastBody = ''.obs;
  var broadcastType = 'global'.obs;
  var broadcastTarget = ''.obs;
  var scheduledAt = Rxn<DateTime>();

  var selectedTab = 0.obs;

  final _apiService = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    loadStaff();
    loadBroadcasts();
    loadRoles();
  }

  // ===========================================================================
  // VALIDATORS
  // ===========================================================================

  String? validateStaffName(String value) {
    if (value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validateStaffEmail(String value) {
    if (value.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value)) return 'Enter a valid email address';
    return null;
  }

  String? validateStaffRole(String value) {
    if (value.isEmpty) return 'Role is required';
    return null;
  }

  String? validateRequired(String value, String field) {
    if (value.isEmpty) return '$field is required';
    return null;
  }

  String? validateEmail(String value) {
    if (value.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value)) return 'Enter a valid email';
    return null;
  }

  String? validateAmount(String value) {
    if (value.isEmpty) return 'Amount is required';
    final n = int.tryParse(value);
    if (n == null || n <= 0) return 'Enter a valid amount';
    return null;
  }

  String? validateWalletUserId(String value) {
    if (value.isEmpty) return 'User ID is required';
    if (!value.startsWith('USR')) return 'Invalid user ID format';
    return null;
  }

  String? validateWalletAmount(String value) {
    if (value.isEmpty) return 'Amount is required';
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return 'Amount must be greater than 0';
    return null;
  }

  String? validateWalletType(String value) {
    if (value != 'coins' && value != 'diamonds') return 'Invalid type';
    return null;
  }

  String? validateWalletAction(String value) {
    if (value != 'add' && value != 'deduct') return 'Invalid action';
    return null;
  }

  String? validateBroadcastTitle(String value) {
    if (value.isEmpty) return 'Title is required';
    if (value.length < 3) return 'Title must be at least 3 characters';
    if (value.length > 100) return 'Title must be 100 characters or less';
    return null;
  }

  String? validateBroadcastBody(String value) {
    if (value.isEmpty) return 'Message body is required';
    if (value.length < 5) return 'Message must be at least 5 characters';
    if (value.length > 500) return 'Message must be 500 characters or less';
    return null;
  }

  String? validateBroadcastTarget(String value) {
    if (broadcastType.value == 'targeted' && value.isEmpty) {
      return 'Target audience is required for targeted messages';
    }
    return null;
  }

  // ===========================================================================
  // USER MANAGEMENT
  // ===========================================================================

  Future<void> loadUsers() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    final allUsers = _generateMockUsers();
    users.value = allUsers;
    totalUsers.value = allUsers.length;
    applyUserFilters();
    _updateStats();
    isLoading.value = false;
  }

  List<Map<String, dynamic>> _generateMockUsers() {
    final names = [
      'Alice', 'Bob', 'Charlie', 'Diana', 'Ethan', 'Fiona', 'George', 'Hannah',
      'Ian', 'Julia', 'Kevin', 'Liam', 'Mia', 'Noah', 'Olivia', 'Peter',
      'Quinn', 'Rachel', 'Sam', 'Tina', 'Umar', 'Violet', 'Will', 'Xena',
      'Yuri', 'Zara'
    ];
    return List.generate(26, (i) {
      final statuses = ['active', 'active', 'active', 'blocked', 'banned'];
      final status = i < 20 ? 'active' : statuses[i % statuses.length];
      return {
        'id': 'USR${String.fromCharCode(65 + i)}${1000 + i}',
        'name': '${names[i]} ${String.fromCharCode(65 + i)}',
        'email': 'user$i@example.com',
        'status': status,
        'coins': 500 + i * 120,
        'diamonds': 10 + i * 5,
        'joined': DateTime.now().subtract(Duration(days: i * 3)),
        'lastActive': DateTime.now().subtract(Duration(hours: i)),
      };
    });
  }

  void applyUserFilters() {
    List<Map<String, dynamic>> result = users;
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((u) {
        return (u['name'] as String).toLowerCase().contains(q) ||
            (u['email'] as String).toLowerCase().contains(q) ||
            (u['id'] as String).toLowerCase().contains(q);
      }).toList();
    }
    if (statusFilter.value != 'all') {
      result = result.where((u) => u['status'] == statusFilter.value).toList();
    }
    filteredUsers.value = result;
    usersPage.value = 1;
    totalUsers.value = result.length;
  }

  void _updateStats() {
    totalUsers.value = users.length;
    activeUsers.value = users.where((u) => u['status'] == 'active').length;
    blockedUsers.value = users.where((u) => u['status'] == 'blocked').length;
    bannedUsers.value = users.where((u) => u['status'] == 'banned').length;
    totalStaff.value = staffMembers.length;
    totalBroadcasts.value = broadcasts.length;
  }

  Future<void> blockUser(String userId) async {
    final user = users.firstWhereOrNull((u) => u['id'] == userId);
    if (user == null) return;
    user['status'] = 'blocked';
    users.refresh();
    applyUserFilters();
    _updateStats();
    await Future.delayed(const Duration(milliseconds: 300));
    Get.snackbar('User Blocked', 'User $userId has been blocked.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(255, 152, 0, 1),
        colorText: Colors.white);
  }

  Future<void> banUser(String userId) async {
    final user = users.firstWhereOrNull((u) => u['id'] == userId);
    if (user == null) return;
    user['status'] = 'banned';
    users.refresh();
    applyUserFilters();
    _updateStats();
    await Future.delayed(const Duration(milliseconds: 300));
    Get.snackbar('User Banned', 'User $userId has been banned.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
        colorText: Colors.white);
  }

  Future<void> unblockUser(String userId) async {
    final user = users.firstWhereOrNull((u) => u['id'] == userId);
    if (user == null) return;
    user['status'] = 'active';
    users.refresh();
    applyUserFilters();
    _updateStats();
    await Future.delayed(const Duration(milliseconds: 300));
    Get.snackbar('User Restored', 'User $userId has been restored.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
        colorText: Colors.white);
  }

  Future<void> toggleUserBlock(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = users.indexWhere((u) => u['id'] == userId || u['_id'] == userId);
    if (idx == -1) return;
    final current = users[idx]['isBlocked'] as bool? ?? false;
    users[idx]['isBlocked'] = !current;
    users.refresh();
    Get.snackbar('Success', 'User ${!current ? 'blocked' : 'unblocked'}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
        colorText: Colors.white);
  }

  Future<void> adjustWallet() async {
    final idErr = validateWalletUserId(walletUserId.value);
    final amtErr = validateWalletAmount(walletAmount.value);
    final typeErr = validateWalletType(walletType.value);
    final actErr = validateWalletAction(walletAction.value);
    if (idErr != null || amtErr != null || typeErr != null || actErr != null) {
      Get.snackbar('Validation Error', 'Please correct the form errors.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    Get.snackbar(
      'Wallet Updated',
      '${walletAction.value == 'add' ? 'Added' : 'Deducted'} ${walletAmount.value} ${walletType.value} for ${walletUserId.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
      colorText: Colors.white,
    );
    walletUserId.value = '';
    walletAmount.value = '';
    walletType.value = 'coins';
    walletAction.value = 'add';
  }

  // ===========================================================================
  // STAFF MANAGEMENT
  // ===========================================================================

  Future<void> loadStaff() async {
    isLoading.value = true;
    await _apiService.get('/staff/list').then((response) {
      if (response['success'] == true) {
        staffMembers.value = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    }).catchError((_) {
      staffMembers.value = List.generate(8, (i) {
        final roles = ['moderator', 'support', 'analyst', 'manager'];
        final perms = i == 0
            ? ['all']
            : ['users.view', 'users.block', 'broadcasts.create', 'wallet.adjust'].sublist(0, 2 + i % 3);
        return {
          'id': 'STF${100 + i}',
          'name': 'Staff Member ${i + 1}',
          'email': 'staff${i + 1}@arvind.party',
          'role': roles[i % roles.length],
          'permissions': perms,
          'createdAt': DateTime.now().subtract(Duration(days: 30 + i * 10)),
          'lastLogin': DateTime.now().subtract(Duration(hours: i * 2)),
        };
      });
    });
    _updateStats();
    isLoading.value = false;
  }

  Future<void> loadRoles() async {
    await _apiService.get('/roles').then((response) {
      if (response['success'] == true) {
        availableRoles.value = List<Map<String, dynamic>>.from(response['data']['roles'] ?? []);
        allPermissions.value = List<String>.from(response['data']['allPermissions'] ?? []);
        roleHierarchy.value = Map<String, dynamic>.from(response['data']['hierarchy'] ?? {});
      }
    }).catchError((_) {});
  }

  Future<void> addStaff() async {
    final nameErr = validateStaffName(staffName.value);
    final emailErr = validateStaffEmail(staffEmail.value);
    final roleErr = validateStaffRole(staffRole.value);
    if (nameErr != null || emailErr != null || roleErr != null) {
      Get.snackbar('Validation Error', 'Please correct the form errors.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
      return;
    }
    isLoading.value = true;
    await _apiService.post('/staff/create', body: {
      'loginId': staffEmail.value.split('@')[0],
      'password': 'TempPass123!',
      'name': staffName.value,
      'email': staffEmail.value,
      'role': staffRole.value,
      'permissions': List<String>.from(staffPermissions),
    }).then((response) {
      if (response['success'] == true) {
        Get.snackbar('Staff Added', '${staffName.value} added successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
            colorText: Colors.white);
        staffName.value = '';
        staffEmail.value = '';
        staffRole.value = '';
        staffPermissions.clear();
        loadStaff();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to add staff',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      }
    }).catchError((_) {
      Get.snackbar('Error', 'Failed to add staff',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    });
    isLoading.value = false;
  }

  Future<void> updateStaff(String id) async {
    final nameErr = validateStaffName(staffName.value);
    final emailErr = validateStaffEmail(staffEmail.value);
    final roleErr = validateStaffRole(staffRole.value);
    if (nameErr != null || emailErr != null || roleErr != null) {
      Get.snackbar('Validation Error', 'Please correct the form errors.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
      return;
    }
    isLoading.value = true;
    await _apiService.put('/staff/update/$id', body: {
      'name': staffName.value,
      'email': staffEmail.value,
      'role': staffRole.value,
      'permissions': List<String>.from(staffPermissions),
    }).then((response) {
      if (response['success'] == true) {
        Get.snackbar('Staff Updated', '${staffName.value} updated.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
            colorText: Colors.white);
        selectedStaffId.value = null;
        staffName.value = '';
        staffEmail.value = '';
        staffRole.value = '';
        staffPermissions.clear();
        loadStaff();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to update staff',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      }
    }).catchError((_) {
      Get.snackbar('Error', 'Failed to update staff',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    });
    isLoading.value = false;
  }

  Future<void> deleteStaff(String id) async {
    isLoading.value = true;
    await _apiService.delete('/staff/delete/$id').then((response) {
      if (response['success'] == true) {
        staffMembers.removeWhere((s) => s['_id'] == id || s['id'] == id);
        _updateStats();
        Get.snackbar('Staff Removed', 'Staff member $id has been removed.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to delete staff',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      }
    }).catchError((_) {
      Get.snackbar('Error', 'Failed to delete staff',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    });
    isLoading.value = false;
  }

  Future<void> selectStaffForEdit(String id) async {
    final member = staffMembers.firstWhereOrNull((s) => s['_id'] == id || s['id'] == id);
    if (member == null) return;
    selectedStaffId.value = id;
    staffName.value = member['name'] ?? '';
    staffEmail.value = member['email'] ?? member['loginId'] ?? '';
    staffPhone.value = member['phone'] ?? '';
    staffRole.value = member['role'] ?? '';
    staffPermissions.value = List.from(member['permissions'] as List<String>? ?? []);
  }

  void togglePermission(String perm) {
    if (staffPermissions.contains(perm)) {
      staffPermissions.remove(perm);
    } else {
      staffPermissions.add(perm);
    }
  }

  // ===========================================================================
  // BROADCASTS
  // ===========================================================================

  Future<void> loadBroadcasts() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    broadcasts.value = [
      {
        'id': 'BRD001',
        'title': 'Welcome to Arvind Party',
        'body': 'Enjoy the new games and features.',
        'type': 'global',
        'sentAt': DateTime.now().subtract(const Duration(days: 1)),
        'sentBy': 'Admin',
      },
      {
        'id': 'BRD002',
        'title': 'Maintenance Notice',
        'body': 'System will be down for 30 minutes.',
        'type': 'global',
        'sentAt': DateTime.now().subtract(const Duration(hours: 12)),
        'sentBy': 'Admin',
      },
    ];
    _updateStats();
    isLoading.value = false;
  }

  Future<void> sendBroadcast() async {
    final titleErr = validateBroadcastTitle(broadcastTitle.value);
    final bodyErr = validateBroadcastBody(broadcastBody.value);
    final targetErr = validateBroadcastTarget(broadcastTarget.value);
    if (titleErr != null || bodyErr != null || targetErr != null) {
      Get.snackbar('Validation Error', 'Please correct the form errors.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 800));
    final newBroadcast = {
      'id': 'BRD${String.fromCharCode(65 + broadcasts.length)}${100 + broadcasts.length}',
      'title': broadcastTitle.value,
      'body': broadcastBody.value,
      'type': broadcastType.value,
      'sentAt': DateTime.now(),
      'sentBy': 'Admin',
      if (broadcastType.value == 'targeted') 'target': broadcastTarget.value,
    };
    broadcasts.insert(0, newBroadcast);
    _updateStats();
    Get.snackbar('Broadcast Sent', 'Announcement sent successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
        colorText: Colors.white);
    broadcastTitle.value = '';
    broadcastBody.value = '';
    broadcastType.value = 'global';
    broadcastTarget.value = '';
    scheduledAt.value = null;
  }

  // ===========================================================================
  // WALLET & REWARDS
  // ===========================================================================

  Future<void> generateCoins(String uid, int amount, String reason) async {
    await Future.delayed(const Duration(milliseconds: 400));
    Get.snackbar('Coins Generated', '+$amount coins to $uid\nReason: $reason',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
        colorText: Colors.white);
  }

  Future<void> deductCoins(String uid, int amount, String reason) async {
    await Future.delayed(const Duration(milliseconds: 400));
    Get.snackbar('Coins Deducted', '-$amount coins from $uid\nReason: $reason',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
        colorText: Colors.white);
  }

  Future<void> processWithdrawal(String withdrawalId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = withdrawals.indexWhere((w) => w['_id'] == withdrawalId);
    if (idx != -1) {
      withdrawals[idx]['status'] = status;
      withdrawals.refresh();
    }
    Get.snackbar('Withdrawal $status', 'Withdrawal $withdrawalId has been $status.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: status == 'approved' ? const Color.fromRGBO(76, 175, 80, 1) : const Color.fromRGBO(244, 67, 54, 1),
        colorText: Colors.white);
  }

  Future<void> sendReward(Map<String, dynamic> params) async {
    await Future.delayed(const Duration(milliseconds: 500));
    Get.snackbar('Reward Sent', 'Reward sent to ${params['uid']}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(255, 152, 0, 1),
        colorText: Colors.white);
  }
}