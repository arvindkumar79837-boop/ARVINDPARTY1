import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/services/api_service.dart';

class BlindDateController extends GetxController {
  final _api = Get.find<ApiService>();
  final _storage = GetStorage();

  final isSearching = false.obs;
  final isCallActive = false.obs;
  final match = Rx<Map<String, dynamic>?>(null);
  final session = Rx<Map<String, dynamic>?>(null);
  final errorMessage = ''.obs;
  final isPreferencesLoaded = false.obs;

  // Preferences
  final genderPreference = 'ANY'.obs;
  final ageRangeMin = 18.obs;
  final ageRangeMax = 35.obs;
  final countryPreference = <String>[].obs;
  final isEnabled = false.obs;

  // Timer
  int remainingSeconds = 120;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  void _loadPreferences() {
    genderPreference.value = _storage.read('bd_genderPref') ?? 'ANY';
    ageRangeMin.value = _storage.read('bd_ageMin') ?? 18;
    ageRangeMax.value = _storage.read('bd_ageMax') ?? 35;
    isEnabled.value = _storage.read('bd_enabled') ?? false;
    isPreferencesLoaded.value = true;
  }

  void savePreferences() {
    _storage.write('bd_genderPref', genderPreference.value);
    _storage.write('bd_ageMin', ageRangeMin.value);
    _storage.write('bd_ageMax', ageRangeMax.value);
    _storage.write('bd_enabled', isEnabled.value);
  }

  Future<void> updateBackendProfile() async {
    try {
      await _api.dio.put('/blind-date/profile', data: {
        'isEnabled': isEnabled.value,
        'genderPreference': genderPreference.value,
        'ageRangeMin': ageRangeMin.value,
        'ageRangeMax': ageRangeMax.value,
        'countryPreference': countryPreference.toList(),
      });
    } catch (e) {
      debugPrint('updateBackendProfile error: $e');
    }
  }

  Future<void> startSearch() async {
    try {
      isSearching.value = true;
      errorMessage.value = '';
      match.value = null;
      await updateBackendProfile();
      final resp = await _api.dio.post('/blind-date/join-queue');
      if (resp.data['success'] != true) {
        errorMessage.value = resp.data['message'] ?? 'Failed to join queue';
        isSearching.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Network error. Try again.';
      isSearching.value = false;
    }
  }

  Future<void> stopSearch() async {
    try {
      await _api.dio.post('/blind-date/leave-queue');
    } catch (_) {}
    isSearching.value = false;
  }

  void onMatchFound(Map<String, dynamic> matchData) {
    match.value = matchData;
    isSearching.value = false;
    isCallActive.value = true;
    final sessionId = matchData['sessionId'];
    if (sessionId != null) _loadSession(sessionId);
  }

  Future<void> _loadSession(String sessionId) async {
    try {
      final resp = await _api.dio.get('/blind-date/session/$sessionId');
      if (resp.data['success'] == true) {
        session.value = resp.data['data'];
      }
    } catch (e) {
      debugPrint('loadSession error: $e');
    }
  }

  Future<void> makeDecision(String decision) async {
    final sessionId = session.value?['sessionId'] ?? match.value?['sessionId'];
    if (sessionId == null) return;
    try {
      final resp = await _api.dio.post('/blind-date/$sessionId/decide', data: {'decision': decision});
      if (resp.data['success'] == true) {
        session.value = {...?session.value, 'myDecision': decision};
        if (resp.data['matched'] == true) {
          session.value = resp.data['data'];
        } else if (resp.data['matched'] == false) {
          // No match — reset
        }
      }
    } catch (e) {
      debugPrint('makeDecision error: $e');
    }
  }

  Future<void> reportSession(String reason) async {
    final sessionId = session.value?['sessionId'] ?? match.value?['sessionId'];
    if (sessionId == null) return;
    try {
      await _api.dio.post('/blind-date/$sessionId/report', data: {'reason': reason, 'description': 'Reported from app'});
      Get.snackbar('Reported', 'Thank you for your report', backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
    } catch (_) {}
    endCall();
  }

  void endCall() {
    isCallActive.value = false;
    match.value = null;
    session.value = null;
    remainingSeconds = 120;
  }

  void reset() {
    isSearching.value = false;
    isCallActive.value = false;
    match.value = null;
    session.value = null;
    errorMessage.value = '';
    remainingSeconds = 120;
  }
}
