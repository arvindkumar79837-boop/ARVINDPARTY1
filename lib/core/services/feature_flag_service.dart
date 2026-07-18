import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FeatureFlagService extends GetxService {
  static FeatureFlagService get instance => Get.find<FeatureFlagService>();
  
  final _box = GetStorage();
  final _flags = <String, bool>{};
  final _serverFlags = <String, Map<String, dynamic>>{};
  
  static const String _storageKey = 'feature_flags';
  static const String _serverFlagsKey = 'server_feature_flags';
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadLocalFlags();
    await _loadServerFlags();
    await _startSyncTimer();
  }
  
  Future<void> _loadLocalFlags() async {
    final stored = _box.read(_storageKey);
    if (stored is Map) {
      _flags.clear();
      for (final entry in stored.entries) {
        _flags[entry.key] = entry.value as bool;
      }
    }
  }
  
  Future<void> _saveLocalFlags() async {
    await _box.write(_storageKey, _flags);
  }
  
  Future<void> _loadServerFlags() async {
    try {
      final apiService = Get.find();
      final response = await apiService.get('/api/infrastructure/feature-flags');
      
      if (response['success'] == true) {
        final flags = response['data'] as List;
        _serverFlags.clear();
        
        for (final flag in flags) {
          final key = flag['key'] as String;
          _serverFlags[key] = Map<String, dynamic>.from(flag);
        }
        
        await _box.write(_serverFlagsKey, _serverFlags);
        await _syncFlags();
      }
    } catch (e) {
      final stored = _box.read(_serverFlagsKey);
      if (stored is Map) {
        _serverFlags.clear();
        for (final entry in stored.entries) {
          _serverFlags[entry.key] = Map<String, dynamic>.from(entry.value as Map);
        }
      }
    }
  }
  
  Future<void> _startSyncTimer() async {
    Future.delayed(const Duration(minutes: 5), () async {
      if (Get.isRegistered()) {
        await _loadServerFlags();
        await _syncFlags();
      }
      await _startSyncTimer();
    });
  }
  
  Future<void> _syncFlags() async {
    for (final entry in _serverFlags.entries) {
      final flag = entry.value;
      final key = entry.key;
      
      if (flag['enabled'] == true) {
        final rolloutPercentage = flag['rolloutPercentage'] ?? 100;
        
        if (rolloutPercentage >= 100) {
          _flags[key] = true;
        } else if (rolloutPercentage > 0) {
          final userId = await _getCurrentUserId();
          if (userId != null) {
            final hash = _hashUserId(userId);
            final bucket = hash % 100;
            _flags[key] = bucket < rolloutPercentage;
          }
        } else {
          _flags[key] = false;
        }
      } else {
        _flags[key] = false;
      }
    }
    
    await _saveLocalFlags();
  }
  
  int _hashUserId(String userId) {
    var hash = 0;
    for (var i = 0; i < userId.length; i++) {
      hash = ((hash << 5) - hash) + userId.codeUnitAt(i);
      hash = hash & hash;
    }
    return hash.abs();
  }
  
  Future<String?> _getCurrentUserId() async {
    try {
      final authBox = GetStorage();
      return authBox.read('user_id') as String?;
    } catch (e) {
      return null;
    }
  }
  
  bool isEnabled(String flagKey) {
    return _flags[flagKey] ?? _getDefaultValue(flagKey);
  }
  
  bool _getDefaultValue(String flagKey) {
    const defaults = {
      'new_games_enabled': false,
      'webview_games': true,
      'advanced_analytics': false,
      'family_war_2v2': false,
      'new_onboarding': true,
      'dark_mode': true,
      'video_gifts': false,
      'ai_recommendations': false,
      'live_streaming': false,
      'crypto_payments': false,
    };
    return defaults[flagKey] ?? false;
  }
  
  Future<void> setFlag(String flagKey, bool value) async {
    _flags[flagKey] = value;
    await _saveLocalFlags();
  }
  
  Future<void> refreshFlags() async {
    await _loadServerFlags();
    await _syncFlags();
  }
  
  Map<String, bool> getAllFlags() {
    return Map.from(_flags);
  }
  
  bool get newGamesEnabled => isEnabled('new_games_enabled');
  bool get webviewGamesEnabled => isEnabled('webview_games');
  bool get advancedAnalyticsEnabled => isEnabled('advanced_analytics');
  bool get familyWar2v2Enabled => isEnabled('family_war_2v2');
  bool get newOnboardingEnabled => isEnabled('new_onboarding');
  bool get darkModeEnabled => isEnabled('dark_mode');
  bool get videoGiftsEnabled => isEnabled('video_gifts');
  bool get aiRecommendationsEnabled => isEnabled('ai_recommendations');
  bool get liveStreamingEnabled => isEnabled('live_streaming');
  bool get cryptoPaymentsEnabled => isEnabled('crypto_payments');
}