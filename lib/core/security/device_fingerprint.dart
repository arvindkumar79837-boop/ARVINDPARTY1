// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/security/device_fingerprint.dart
// ARVIND PARTY - DEVICE FINGERPRINTING SERVICE
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceFingerprint {
  static const String _deviceIdKey = 'device_fingerprint';
  static final DeviceFingerprint _instance = DeviceFingerprint._internal();
  factory DeviceFingerprint() => _instance;
  DeviceFingerprint._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String? _cachedFingerprint;

  /// Get device fingerprint - unique identifier for the device
  Future<String> getFingerprint() async {
    // Return cached fingerprint if available
    if (_cachedFingerprint != null) {
      return _cachedFingerprint!;
    }

    try {
      // Try to get cached fingerprint from storage first
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_deviceIdKey);
      if (cached != null && cached.isNotEmpty) {
        _cachedFingerprint = cached;
        return cached;
      }

      // Collect device information
      Map<String, dynamic> deviceData = {};

      if (defaultTargetPlatform == TargetPlatform.android) {
        deviceData = await _getAndroidFingerprint();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        deviceData = await _getIOSFingerprint();
      } else {
        deviceData = await _getWebFingerprint();
      }

      // Add platform-agnostic data
      deviceData['platform'] = defaultTargetPlatform.toString();
      deviceData['timestamp'] = DateTime.now().millisecondsSinceEpoch;

      // Generate fingerprint from collected data
      final fingerprint = _generateFingerprintHash(deviceData);

      // Cache the fingerprint
      await prefs.setString(_deviceIdKey, fingerprint);
      _cachedFingerprint = fingerprint;

      debugPrint('[DeviceFingerprint] Generated: $fingerprint');
      return fingerprint;
    } catch (e) {
      debugPrint('[DeviceFingerprint] Error: $e, generating fallback fingerprint');
      // Generate a fallback fingerprint
      return _generateFallbackFingerprint();
    }
  }

  /// Collect Android device information
  Future<Map<String, dynamic>> _getAndroidFingerprint() async {
    try {
      final info = await _deviceInfo.androidInfo;
      return {
        'androidId': info.id,
        'model': info.model,
        'manufacturer': info.manufacturer,
        'brand': info.brand,
        'device': info.device,
        'product': info.product,
        'hardware': info.hardware,
        'display': info.display,
        'fingerprint': info.fingerprint,
        'host': info.host,
        'tags': info.tags,
        'type': info.type,
        'systemFeatures': info.systemFeatures,
      };
    } catch (e) {
      debugPrint('[DeviceFingerprint] Android info error: $e');
      return {'error': 'android_info_failed'};
    }
  }

  /// Collect iOS device information
  Future<Map<String, dynamic>> _getIOSFingerprint() async {
    try {
      final info = await _deviceInfo.iosInfo;
      return {
        'identifierForVendor': info.identifierForVendor,
        'model': info.model,
        'systemName': info.systemName,
        'systemVersion': info.systemVersion,
        'name': info.name,
        'localizedModel': info.localizedModel,
        'utsname': {
          'machine': info.utsname.machine,
          'version': info.utsname.version,
          'release': info.utsname.release,
        },
      };
    } catch (e) {
      debugPrint('[DeviceFingerprint] iOS info error: $e');
      return {'error': 'ios_info_failed'};
    }
  }

  /// Collect web device information
  Future<Map<String, dynamic>> _getWebFingerprint() async {
    try {
      // In browser context, we use browser fingerprinting
      return {
        'userAgent': '$defaultTargetPlatform',
        'viewport': '$defaultTargetPlatform',
      };
    } catch (e) {
      debugPrint('[DeviceFingerprint] Web info error: $e');
      return {'error': 'web_info_failed'};
    }
  }

  /// Generate MD5 hash from device data
  String _generateFingerprintHash(Map<String, dynamic> data) {
    // Sort keys for consistent hashing
    final sortedKeys = data.keys.toList()..sort();
    final buffer = StringBuffer();
    for (final key in sortedKeys) {
      buffer.write('$key:${data[key]};');
    }
    final bytes = utf8.encode(buffer.toString());
    final hash = md5.convert(bytes);
    return hash.toString().substring(0, 32); // Use first 32 chars
  }

  /// Generate fallback fingerprint when device info fails
  String _generateFallbackFingerprint() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final hash = md5.convert(bytes);
    return hash.toString().substring(0, 32);
  }

  /// Get device info for analytics/logging
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': info.model,
          'manufacturer': info.manufacturer,
          'androidVersion': info.version.sdkInt.toString(),
          'fingerprint': _cachedFingerprint,
        };
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': info.model,
          'systemVersion': info.systemVersion,
          'fingerprint': _cachedFingerprint,
        };
      } else {
        return {
          'platform': 'web',
          'fingerprint': _cachedFingerprint,
        };
      }
    } catch (e) {
      debugPrint('[DeviceFingerprint] getDeviceInfo error: $e');
      return {'fingerprint': _cachedFingerprint};
    }
  }

  /// Clear cached fingerprint (force regeneration on next getFingerprint call)
  Future<void> clearFingerprint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
      _cachedFingerprint = null;
      debugPrint('[DeviceFingerprint] Cleared');
    } catch (e) {
      debugPrint('[DeviceFingerprint] Clear error: $e');
    }
  }
}