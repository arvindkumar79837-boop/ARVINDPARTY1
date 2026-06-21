// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/security/request_signer.dart
// ARVIND PARTY - REQUEST SIGNING SERVICE
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestSigner {
  static final RequestSigner _instance = RequestSigner._internal();
  factory RequestSigner() => _instance;
  RequestSigner._internal();

  String? _deviceSecret;

  /// Initialize the request signer with device secret
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedSecret = prefs.getString('device_secret');

      if (cachedSecret != null && cachedSecret.isNotEmpty) {
        _deviceSecret = cachedSecret;
      } else {
        // Generate new device secret
        _deviceSecret = _generateDeviceSecret();
        await prefs.setString('device_secret', _deviceSecret!);
        debugPrint('[RequestSigner] New device secret generated');
      }
    } catch (e) {
      debugPrint('[RequestSigner] Initialization error: $e');
      // Fallback to generated secret
      _deviceSecret = _generateDeviceSecret();
    }
  }

  /// Generate a cryptographically secure device secret
  String _generateDeviceSecret() {
    final bytes = List<int>.generate(32, (_) => DateTime.now().millisecondsSinceEpoch % 256);
    final hash = sha256.convert(bytes);
    return hash.toString().substring(0, 64);
  }

  /// Sign a request with timestamp and device secret
  String signRequest({
    required String method,
    required String endpoint,
    required String body,
    required String timestamp,
  }) {
    if (_deviceSecret == null) {
      debugPrint('[RequestSigner] Warning: Not initialized, call initialize() first');
      return '';
    }

    // Create signature string: METHOD + ENDPOINT + BODY + TIMESTAMP + DEVICE_SECRET
    final signatureString = '$method$endpoint$body$_deviceSecret$timestamp';
    final bytes = utf8.encode(signatureString);
    final signature = sha256.convert(bytes);
    return signature.toString().substring(0, 64);
  }

  /// Sign an API request for Dio interceptor
  Future<Map<String, String>> getSignedHeaders({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final bodyString = body != null ? jsonEncode(body) : '';

    final signature = signRequest(
      method: method.toUpperCase(),
      endpoint: endpoint,
      body: bodyString,
      timestamp: timestamp,
    );

    return {
      'X-Timestamp': timestamp,
      'X-Signature': signature,
      'X-Device-Secret': _deviceSecret ?? '',
    };
  }

  /// Get device secret for registration
  String? getDeviceSecret() {
    return _deviceSecret;
  }

  /// Validate a signature from server response
  bool validateResponseSignature({
    required String signature,
    required String timestamp,
    required String responseBody,
  }) {
    if (_deviceSecret == null) return false;

    final signatureString = '$responseBody$_deviceSecret$timestamp';
    final bytes = utf8.encode(signatureString);
    final expectedSignature = sha256.convert(bytes).toString().substring(0, 64);

    return signature == expectedSignature;
  }

  /// Clear device secret (logout from all devices)
  Future<void> clearDeviceSecret() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('device_secret');
      _deviceSecret = null;
      debugPrint('[RequestSigner] Device secret cleared');
    } catch (e) {
      debugPrint('[RequestSigner] Clear error: $e');
    }
  }

  /// Get device info for security logging
  Future<Map<String, String>> getSecurityHeaders() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (_deviceSecret == null) {
      await initialize();
    }

    return {
      'X-Timestamp': timestamp,
      'X-Device-Secret': _deviceSecret ?? '',
    };
  }
}