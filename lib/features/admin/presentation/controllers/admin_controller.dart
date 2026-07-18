import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service.dart';
import '../repositories/admin_repository.dart';

class AdminController extends GetxController {
  final AdminRepository _repo = AdminRepository();
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

  String? validateWalletUserId(String? value) {
    if (value == null || value.isEmpty) return 'User ID is required';
    return null;
  }

  String? validateWalletAmount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
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
    errorMessage.value = '';
    try {
      final fetchedUsers = await _repo.getUsers();
      users.value = fetchedUsers;
      totalUsers.value = fetchedUsers.length;
      applyUserFilters();
      _updateStats();
    } catch (e) {
      errorMessage.value = 'Failed to load users: $e';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void applyUserFilters() {
    List<Map<String, dynamic>> result = users;
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((u) {
        return (u['name'] as String? ?? '').toLowerCase().contains(q) ||
            (u['email'] as String? ?? '').toLowerCase().contains(q) ||
            (u['id'] as String? ?? u['_id'] as String? ?? '').toLowerCase().contains(q);
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
    activeUsers.value = users.where((u) => u['status'] == 'active' || u['isBlocked'] != true).length;
    blockedUsers.value = users.where((u) => u['status'] == 'blocked' || u['isBlocked'] == true).length;
    bannedUsers.value = users.where((u) => u['status'] == 'banned').length;
    totalStaff.value = staffMembers.length;
    totalBroadcasts.value = broadcasts.length;
  }

  Future<void> blockUser(String userId) async {
    isLoading.value = true;
    try {
      final response = await _repo.toggleBlock(userId);
      if (response['success'] == true) {
        final idx = users.indexWhere((u) => u['id'] == userId || u['_id'] == userId);
        if (idx != -1) {
          users[idx]['status'] = 'blocked';
          users[idx]['isBlocked'] = true;
          users.refresh();
        }
        applyUserFilters();
        _updateStats();
        Get.snackbar('User Blocked', 'User $userId has been blocked.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(255, 152, 0, 1),
            colorText: Colors.white);
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to block user',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to block user: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> banUser(String userId) async {
    isLoading.value = true;
    try {
      final response = await _apiService.post('/admin/users/ban/$userId');
      if (response is Map && response['success'] == true) {
        final idx = users.indexWhere((u) => u['id'] == userId || u['_id'] == userId);
        if (idx != -1) {
          users[idx]['status'] = 'banned';
          users.refresh();
        }
        applyUserFilters();
        _updateStats();
        Get.snackbar('User Banned', 'User $userId has been banned.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to ban user',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to ban user: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unblockUser(String userId) async {
    isLoading.value = true;
    try {
      final response = await _apiService.post('/admin/users/unblock/$userId');
      if (response is Map && response['success'] == true) {
        final idx = users.indexWhere((u) => u['id'] == userId || u['_id'] == userId);
        if (idx != -1) {
          users[idx]['status'] = 'active';
          users[idx]['isBlocked'] = false;
          users.refresh();
        }
        applyUserFilters();
        _updateStats();
        Get.snackbar('User Restored', 'User $userId has been restored.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
            colorText: Colors.white);
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to restore user',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to restore user: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleUserBlock(String userId) async {
    isLoading.value = true;
    try {
      final response = await _repo.toggleBlock(userId);
      if (response['success'] == true) {
        final idx = users.indexWhere((u) => u['id'] == userId || u['_id'] == userId);
        if (idx != -1) {
          final current = users[idx]['isBlocked'] as bool? ?? false;
          users[idx]['isBlocked'] = !current;
          users[idx]['status'] = !current ? 'blocked' : 'active';
          users.refresh();
        }
        applyUserFilters();
        _updateStats();
        final newBlockedState = response['isBlocked'] ?? response['data']?['isBlocked'];
        Get.snackbar('Success', 'User ${newBlockedState == true ? 'blocked' : 'unblocked'}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle block: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
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

    isLoading.value = true;
    try {
      final amount = int.tryParse(walletAmount.value) ?? 0;
      final reason = 'Admin ${walletAction.value == 'add' ? 'credit' : 'deduction'}';
      Map<String, dynamic> response;

      if (walletAction.value == 'add') {
        response = await _repo.generateCoins(walletUserId.value, amount, reason);
      } else {
        response = await _repo.deductCoins(walletUserId.value, amount, reason);
      }

      if (response['success'] == true) {
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
        await loadUsers();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Wallet update failed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Wallet update failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================================================
  // STAFF MANAGEMENT
  // ===========================================================================

  Future<void> loadStaff() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/staff/list');
      if (response is Map && response['success'] == true) {
        staffMembers.value = List<Map<String, dynamic>>.from(response['data'] ?? []);
      } else {
        staffMembers.clear();
        Get.snackbar('Error', 'Failed to load staff');
      }
    } catch (e) {
      staffMembers.clear();
      Get.snackbar('Error', 'Failed to load staff: $e');
    } finally {
      _updateStats();
      isLoading.value = false;
    }
  }

  Future<void> loadRoles() async {
    try {
      final response = await _apiService.get('/roles');
      if (response is Map && response['success'] == true) {
        availableRoles.value = List<Map<String, dynamic>>.from(response['data']['roles'] ?? []);
        allPermissions.value = List<String>.from(response['data']['allPermissions'] ?? []);
        roleHierarchy.value = Map<String, dynamic>.from(response['data']['hierarchy'] ?? {});
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load roles: $e');
    }
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
    try {
      final response = await _apiService.post('/staff/create', body: {
        'loginId': staffEmail.value.split('@')[0],
        'password': 'TempPass123!',
        'name': staffName.value,
        'email': staffEmail.value,
        'role': staffRole.value,
        'permissions': List<String>.from(staffPermissions),
      });
      if (response is Map && response['success'] == true) {
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
    } catch (e) {
      Get.snackbar('Error', 'Failed to add staff: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
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
    try {
      final response = await _apiService.put('/staff/update/$id', body: {
        'name': staffName.value,
        'email': staffEmail.value,
        'role': staffRole.value,
        'permissions': List<String>.from(staffPermissions),
      });
      if (response is Map && response['success'] == true) {
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
    } catch (e) {
      Get.snackbar('Error', 'Failed to update staff: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStaff(String id) async {
    isLoading.value = true;
    try {
      final response = await _apiService.delete('/staff/delete/$id');
      if (response is Map && response['success'] == true) {
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
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete staff: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
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
    try {
      final response = await _apiService.get('/broadcasts');
      if (response is Map && response['success'] == true) {
        broadcasts.value = List<Map<String, dynamic>>.from(response['data'] ?? []);
      } else {
        broadcasts.clear();
      }
    } catch (e) {
      broadcasts.clear();
      Get.snackbar('Error', 'Failed to load broadcasts: $e');
    } finally {
      _updateStats();
      isLoading.value = false;
    }
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

    isLoading.value = true;
    try {
      final response = await _apiService.post('/broadcasts/send', body: {
        'title': broadcastTitle.value,
        'body': broadcastBody.value,
        'type': broadcastType.value,
        if (broadcastType.value == 'targeted') 'target': broadcastTarget.value,
        if (scheduledAt.value != null) 'scheduledAt': scheduledAt.value!.toIso8601String(),
      });

      if (response is Map && response['success'] == true) {
        final newBroadcast = response['data'] as Map<String, dynamic>? ?? {
          'title': broadcastTitle.value,
          'body': broadcastBody.value,
          'type': broadcastType.value,
          'sentAt': DateTime.now().toIso8601String(),
          'sentBy': 'Admin',
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
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to send broadcast',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send broadcast: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================================================
  // WALLET & REWARDS
  // ===========================================================================

  Future<void> generateCoins(String uid, int amount, String reason) async {
    isLoading.value = true;
    try {
      final response = await _repo.generateCoins(uid, amount, reason);
      if (response['success'] == true) {
        Get.snackbar('Coins Generated', '+$amount coins to $uid\nReason: $reason',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
            colorText: Colors.white);
        await loadUsers();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to generate coins',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate coins: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deductCoins(String uid, int amount, String reason) async {
    isLoading.value = true;
    try {
      final response = await _repo.deductCoins(uid, amount, reason);
      if (response['success'] == true) {
        Get.snackbar('Coins Deducted', '-$amount coins from $uid\nReason: $reason',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
        await loadUsers();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to deduct coins',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to deduct coins: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadWithdrawals() async {
    isLoading.value = true;
    try {
      final fetched = await _repo.getWithdrawals();
      withdrawals.value = fetched;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load withdrawals: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processWithdrawal(String withdrawalId, String status) async {
    isLoading.value = true;
    try {
      final response = await _repo.processWithdrawal(withdrawalId, status);
      if (response['success'] == true) {
        final idx = withdrawals.indexWhere((w) => w['_id'] == withdrawalId || w['id'] == withdrawalId);
        if (idx != -1) {
          withdrawals[idx]['status'] = status;
          withdrawals.refresh();
        }
        Get.snackbar('Withdrawal ${status[0].toUpperCase()}${status.substring(1)}',
            'Withdrawal $withdrawalId has been $status.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: status == 'approved'
                ? const Color.fromRGBO(76, 175, 80, 1)
                : const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to process withdrawal',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to process withdrawal: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendReward(Map<String, dynamic> params) async {
    isLoading.value = true;
    try {
      final response = await _repo.sendReward(params);
      if (response['success'] == true) {
        Get.snackbar('Reward Sent', 'Reward sent to ${params['uid']}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(255, 152, 0, 1),
            colorText: Colors.white);
        await loadUsers();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to send reward',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send reward: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
