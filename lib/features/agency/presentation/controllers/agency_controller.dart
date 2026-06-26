import 'package:get/get.dart';
import '../repositories/agency_repository.dart';

class AgencyController extends GetxController {
  final isLoading = false.obs;
  final isCreating = false.obs;
  final agencyData = Rxn<Map<String, dynamic>>();
  final members = <Map<String, dynamic>>[].obs;
  final earnings = Rxn<Map<String, dynamic>>();
  final liveAttendance = Rxn<Map<String, dynamic>>();
  final salaryHistory = <Map<String, dynamic>>[].obs;
  final hostRequests = <Map<String, dynamic>>[].obs;
  final agents = <Map<String, dynamic>>[].obs;
  final bonuses = <Map<String, dynamic>>[].obs;
  final penalties = <Map<String, dynamic>>[].obs;
  final withdrawals = <Map<String, dynamic>>[].obs;
  final monthlyReport = Rxn<Map<String, dynamic>>();
  final realtimeAnalytics = Rxn<Map<String, dynamic>>();

  late final AgencyRepository _agencyRepository = Get.find<AgencyRepository>();

  @override
  void onInit() {
    super.onInit();
    loadAgencyData();
    fetchRealtimeAnalytics();
  }

  Future<void> loadAgencyData() async {
    try {
      isLoading.value = true;
      agencyData.value = await _agencyRepository.fetchData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load agency data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMembers() async {
    try {
      isLoading.value = true;
      final fetchedMembers = await _agencyRepository.fetchMembers();
      members.assignAll(fetchedMembers);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load agency members');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAgency({
    required String name,
    String? description,
    String? logo,
  }) async {
    try {
      isCreating.value = true;
      final result = await _agencyRepository.createAgency(
        name: name,
        description: description,
        logo: logo,
      );

      if (result['success'] == true) {
        agencyData.value = result['agency'] as Map<String, dynamic>? ?? result;
        Get.back();
        Get.snackbar('Success', 'Agency created successfully');
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to create agency');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create agency: ${e.toString()}');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> fetchEarnings() async {
    try {
      isLoading.value = true;
      earnings.value = await _agencyRepository.fetchEarnings();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch agency earnings');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startAttendanceSession({String? roomId}) async {
    try {
      isLoading.value = true;
      final result = await _agencyRepository.startAttendanceSession(roomId: roomId);
      if (result['success'] == true) {
        Get.snackbar('Success', 'Attendance session started');
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to start session');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start attendance session');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> endAttendanceSession() async {
    try {
      isLoading.value = true;
      final result = await _agencyRepository.endAttendanceSession();
      if (result['success'] == true) {
        Get.snackbar('Success', 'Attendance session ended');
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to end session');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to end attendance session');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLiveAttendance() async {
    try {
      final result = await _agencyRepository.getLiveAttendance();
      liveAttendance.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load live attendance');
    }
  }

  Future<void> fetchSalaryHistory({int? month, int? year}) async {
    try {
      isLoading.value = true;
      final result = await _agencyRepository.getSalaryHistory(month: month, year: year);
      if (result['success'] == true) {
        salaryHistory.assignAll(List<Map<String, dynamic>>.from(result['data'] ?? []));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load salary history');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHostRequests() async {
    try {
      final result = await _agencyRepository.getHostRequests();
      if (result['success'] == true) {
        hostRequests.assignAll(List<Map<String, dynamic>>.from(result['data'] ?? []));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load host requests');
    }
  }

  Future<void> approveHostRequest(String requestId, {String? reviewNotes}) async {
    try {
      final result = await _agencyRepository.approveHostRequest(requestId, reviewNotes: reviewNotes);
      if (result['success'] == true) {
        Get.snackbar('Success', 'Host request approved');
        fetchHostRequests();
        fetchMembers();
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to approve request');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve host request');
    }
  }

  Future<void> rejectHostRequest(String requestId, {String? reviewNotes}) async {
    try {
      final result = await _agencyRepository.rejectHostRequest(requestId, reviewNotes: reviewNotes);
      if (result['success'] == true) {
        Get.snackbar('Success', 'Host request rejected');
        fetchHostRequests();
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to reject request');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject host request');
    }
  }

  Future<void> sendHostRequest(String targetUid, {String? message}) async {
    try {
      isLoading.value = true;
      final result = await _agencyRepository.sendHostRequest(targetUid, message: message);
      if (result['success'] == true) {
        Get.snackbar('Success', 'Host request sent');
        Get.back();
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to send request');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send host request');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAgents() async {
    try {
      final result = await _agencyRepository.getAgents();
      if (result['success'] == true) {
        agents.assignAll(List<Map<String, dynamic>>.from(result['data'] ?? []));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load agents');
    }
  }

  Future<void> addAgent(String uid, {double commissionRate = 5.0}) async {
    try {
      isLoading.value = true;
      final result = await _agencyRepository.addAgent(uid, commissionRate: commissionRate);
      if (result['success'] == true) {
        Get.snackbar('Success', 'Agent added');
        fetchAgents();
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to add agent');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add agent');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMonthlyReport({int? month, int? year}) async {
    try {
      final result = await _agencyRepository.getMonthlyReport(month: month, year: year);
      monthlyReport.value = result['data'] as Map<String, dynamic>?;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load monthly report');
    }
  }

  Future<void> fetchRealtimeAnalytics() async {
    try {
      final result = await _agencyRepository.getRealtimeAnalytics();
      realtimeAnalytics.value = result['data'] as Map<String, dynamic>?;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load analytics');
    }
  }

  Future<void> awardBonusToHost({
    required String hostId,
    required String reason,
    required double amount,
    String type = 'coins',
  }) async {
    try {
      isLoading.value = true;
      final result = await _agencyRepository.awardBonus(
        hostId: hostId,
        reason: reason,
        amount: amount,
        type: type,
      );
      if (result['success'] == true) {
        Get.snackbar('Success', 'Bonus awarded');
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to award bonus');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to award bonus');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyPenaltyToHost({
    required String hostId,
    required String reason,
    required double amount,
    String type = 'coins',
  }) async {
    try {
      isLoading.value = true;
      final result = await _agencyRepository.applyPenalty(
        hostId: hostId,
        reason: reason,
        amount: amount,
        type: type,
      );
      if (result['success'] == true) {
        Get.snackbar('Success', 'Penalty applied');
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to apply penalty');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to apply penalty');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestWithdrawal({
    required double amount,
    String currency = 'coins',
  }) async {
    try {
      isLoading.value = true;
      final result = await _agencyRepository.requestWithdrawal(
        amount: amount,
        currency: currency,
      );
      if (result['success'] == true) {
        Get.snackbar('Success', 'Withdrawal request submitted');
        Get.back();
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to request withdrawal');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to request withdrawal');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWithdrawalHistory() async {
    try {
      final result = await _agencyRepository.getWithdrawalHistory();
      if (result['success'] == true) {
        withdrawals.assignAll(List<Map<String, dynamic>>.from(result['data'] ?? []));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load withdrawal history');
    }
  }

  Future<Map<String, dynamic>?> getHostAgencyDashboard() async {
    try {
      isLoading.value = true;
      final result = await _agencyRepository.getHostAgencyDashboard();
      if (result['success'] == true) {
        return result['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load host dashboard');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> getOwnerAgencyDashboard() async {
    try {
      isLoading.value = true;
      final result = await _agencyRepository.getOwnerAgencyDashboard();
      if (result['success'] == true) {
        return result['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load owner dashboard');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getAgencyMonthlyHistory({int months = 6}) async {
    try {
      isLoading.value = true;
      final result = await _agencyRepository.getAgencyMonthlyHistory(months: months);
      if (result['success'] == true) {
        final historyData = result['data'] as Map<String, dynamic>?;
        final history = historyData?['history'] as List<dynamic>? ?? [];
        return List<Map<String, dynamic>>.from(history);
      }
      return [];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load monthly history');
      return [];
    } finally {
      isLoading.value = false;
    }
  }
}
