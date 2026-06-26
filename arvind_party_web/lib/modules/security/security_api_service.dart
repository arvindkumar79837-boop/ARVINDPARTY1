// ═══════════════════════════════════════════════════════════════════════════
// SERVICE: SecurityApiService — HTTP client for Security Module
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/api_service.dart';
import '../../routes/app_routes.dart';

class SecurityApiService extends GetxService {
  final _box = GetStorage();
  final ApiService _api;

  SecurityApiService(this._api);

  Future<Map<String, dynamic>> getDashboard() async {
    return await _api.get(AppRoutes.securityDashboard);
  }

  Future<Map<String, dynamic>> getFraudAlerts({int page = 1, int limit = 20, String? severity, String? status}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (severity != null) params['severity'] = severity;
    if (status != null) params['status'] = status;
    final uri = Uri.parse('${_resolveBase()}/security/fraud-alerts').replace(queryParameters: params);
    final response = await _getDirect(uri.toString());
    return response;
  }

  Future<Map<String, dynamic>> updateFraudAlert(String alertId, Map<String, dynamic> body) async {
    return await _putDirect('${_resolveBase()}/security/fraud-alerts/$alertId', body);
  }

  Future<Map<String, dynamic>> getBannedDevices() async => await _getDirect('${_resolveBase()}/security/banned-devices');
  Future<Map<String, dynamic>> banDevice({required String deviceId, String reason = 'Violation of platform policies.'}) async => await _postDirect('${_resolveBase()}/security/banned-devices', {'deviceId': deviceId, 'reason': reason});
  Future<Map<String, dynamic>> unbanDevice(String deviceId) async => await _deleteDirect('${_resolveBase()}/security/banned-devices/$deviceId');
  Future<Map<String, dynamic>> getBlockedIps() async => await _getDirect('${_resolveBase()}/security/blocked-ips');
  Future<Map<String, dynamic>> blockIp({required String ipAddress, String reason = 'Security violation', bool permanent = false}) async => await _postDirect('${_resolveBase()}/security/blocked-ips', {'ipAddress': ipAddress, 'reason': reason, 'isPermanent': permanent});
  Future<Map<String, dynamic>> unblockIp(String ipId) async => await _deleteDirect('${_resolveBase()}/security/blocked-ips/$ipId');
  Future<Map<String, dynamic>> getAuditLogs({int page = 1, int limit = 50, String? action}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (action != null) params['action'] = action;
    return await _getDirect('${_resolveBase()}/security/audit-logs?${Uri(queryParameters: params).query}');
  }
  Future<Map<String, dynamic>> getLiveThreats() async => await _getDirect('${_resolveBase()}/security/live-threats');

  static const String _defaultBase = 'http://localhost:5000/api';
  String _resolveBase() {
    final stored = _box.read('api_base_url');
    return stored != null ? stored as String : _defaultBase;
  }
}

extension SecurityApiHelpers on SecurityApiService {
  Future<Map<String, dynamic>> _getDirect(String url) async {
    final token = _box.read('auth_token') as String?;
    final headers = {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
    return _decode(response);
  }

  Future<Map<String, dynamic>> _postDirect(String url, Map<String, dynamic> body) async {
    final token = _box.read('auth_token') as String?;
    final headers = {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 30));
    return _decode(response);
  }

  Future<Map<String, dynamic>> _putDirect(String url, Map<String, dynamic> body) async {
    final token = _box.read('auth_token') as String?;
    final headers = {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
    final response = await http.put(Uri.parse(url), headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 30));
    return _decode(response);
  }

  Future<Map<String, dynamic>> _deleteDirect(String url) async {
    final token = _box.read('auth_token') as String?;
    final headers = {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
    final response = await http.delete(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 30));
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    try { return jsonDecode(response.body) as Map<String, dynamic>; }
    catch (_) { return {'success': false, 'message': 'Invalid response format'}; }
  }
}