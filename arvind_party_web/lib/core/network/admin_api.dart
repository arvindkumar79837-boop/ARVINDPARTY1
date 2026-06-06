// arvind_party_web/lib/core/network/admin_api.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';

class AdminApi extends GetxService {
  final _box = GetStorage();

  Map<String, String> get _headers => {
    'Content-Type':  'application/json',
    'x-admin-key':   ApiConstants.adminKey,
    'Authorization': 'Bearer ${_box.read<String>('admin_token') ?? ''}',
  };

  // ─── AUTH ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> adminLogin(String phone) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.apiBaseUrl}/auth/firebase-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    return jsonDecode(res.body);
  }

  // ─── DASHBOARD ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await http.get(
      Uri.parse('${ApiConstants.apiBaseUrl}/admin/stats'),
      headers: _headers,
    );
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getActiveRooms() async {
    final res = await http.get(
      Uri.parse('${ApiConstants.apiBaseUrl}/rooms/live'),
      headers: _headers,
    );
    final data = jsonDecode(res.body);
    return data is List ? data : data['rooms'] ?? [];
  }

  // ─── USERS ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getAllUsers({int page = 1, int limit = 20}) async {
    final res = await http.get(
      Uri.parse('${ApiConstants.apiBaseUrl}/admin/users?page=$page&limit=$limit'),
      headers: _headers,
    );
    return jsonDecode(res.body);
  }

  Future<bool> blockUser(String userId) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.apiBaseUrl}/admin/users/ban'),
      headers: _headers,
      body: jsonEncode({'userId': userId}),
    );
    final data = jsonDecode(res.body);
    return data['success'] == true;
  }

  Future<bool> unblockUser(String userId) async {
    final res = await http.put(
      Uri.parse('${ApiConstants.apiBaseUrl}/admin/users/$userId/unblock'),
      headers: _headers,
    );
    final data = jsonDecode(res.body);
    return data['success'] == true;
  }

  Future<bool> adjustCoins(String userId, int coins, String reason) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.apiBaseUrl}/admin/users/balance'),
      headers: _headers,
      body: jsonEncode({'userId': userId, 'amount': coins, 'reason': reason}),
    );
    final data = jsonDecode(res.body);
    return data['success'] == true;
  }

  // ─── GIFTS ─────────────────────────────────────────────────────────────────
  Future<List<dynamic>> getGifts() async {
    final res = await http.get(
      Uri.parse('${ApiConstants.apiBaseUrl}/gifts'),
      headers: _headers,
    );
    final data = jsonDecode(res.body);
    return data['gifts'] ?? [];
  }

  Future<bool> addGift(Map<String, dynamic> gift) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.apiBaseUrl}/gifts'),
      headers: _headers,
      body: jsonEncode(gift),
    );
    final data = jsonDecode(res.body);
    return data['success'] == true;
  }

  Future<bool> deleteGift(String giftId) async {
    final res = await http.delete(
      Uri.parse('${ApiConstants.apiBaseUrl}/gifts/$giftId'),
      headers: _headers,
    );
    final data = jsonDecode(res.body);
    return data['success'] == true;
  }

  // ─── WITHDRAWALS ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getPendingWithdrawals() async {
    final res = await http.get(
      Uri.parse('${ApiConstants.apiBaseUrl}/admin/withdrawals/pending'),
      headers: _headers,
    );
    return jsonDecode(res.body);
  }

  Future<bool> processWithdrawal(String transactionId, String action) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.apiBaseUrl}/admin/withdrawals/process'),
      headers: _headers,
      body: jsonEncode({'transactionId': transactionId, 'action': action}),
    );
    final data = jsonDecode(res.body);
    return data['success'] == true;
  }

  // ─── ANNOUNCEMENTS ──────────────────────────────────────────────────────────
  Future<bool> createAnnouncement(String title, String message) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.apiBaseUrl}/admin/announcement'),
      headers: _headers,
      body: jsonEncode({'title': title, 'message': message}),
    );
    final data = jsonDecode(res.body);
    return data['success'] == true;
  }

  static AdminApi get to => Get.find<AdminApi>();
}
