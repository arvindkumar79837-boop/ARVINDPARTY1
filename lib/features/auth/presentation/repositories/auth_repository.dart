// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/repositories/auth_repository.dart
// ARVIND PARTY - AUTH REPOSITORY (REST API with Dio + AuthSessionManager)
// MATCHES BACKEND: /api/auth/send-otp, /api/auth/otp-verify, /api/auth/register, /api/auth/logout, /api/auth/me
// ═══════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';
import '../../models/auth_model.dart';

class AuthRepository {
  ApiService get _apiService => Get.find<ApiService>();

  AuthRepository();

  AuthSessionManager get _session {
    return Get.find<AuthSessionManager>();
  }

  String _getAuthHeader() {
    final token = _session.token.value;
    if (token == null || token.isEmpty) return '';
    return 'Bearer $token';
  }

  /// Send OTP via phone number
  /// Matches backend: POST /api/auth/send-otp { phone: "9876543210" }
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response =  await _apiService.dio.post(
        '/auth/send-otp',
        data: {'phone': phone},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Verify OTP - THE single entry point for both new and returning users
  /// Matches backend: POST /api/auth/otp-verify { phone: "9876543210", otp: "123456" }
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response =  await _apiService.dio.post(
        '/auth/otp-verify',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      final data =  response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final auth =  AuthResponse.fromBackendJson(data);
        await _session.saveSession(
          token: auth.token,
          userId: auth.user.id,
          userName: auth.user.username,
          userEmail: auth.user.email,
          userAvatar: auth.user.profileImage ?? '',
          userPhone: phone,
        );
        return auth;
      }
      throw ApiException(message: data['message'] ?? 'OTP verification failed');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException.unauthorized();
      }
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Resend OTP
  /// Matches backend: POST /api/auth/resend-otp { phone: "9876543210" }
  Future<Map<String, dynamic>> resendOtp(String phone) async {
    try {
      final response =  await _apiService.dio.post(
        '/auth/resend-otp',
        data: {'phone': phone},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Register/Complete profile after OTP
  /// Matches backend: POST /api/auth/register { phone, name, gender?, dob? }
  Future<AuthResponse> register({
    required String phone,
    required String name,
    String? gender,
    DateTime? dob,
  }) async {
    try {
      final response =  await _apiService.dio.post(
        '/auth/register',
        data: {
          'phone': phone,
          'name': name,
          if (gender != null) 'gender': gender,
          if (dob != null) 'dob': dob.toIso8601String(),
        },
      );

      final data =  response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final auth =  AuthResponse.fromBackendJson(data);
        await _session.saveSession(
          token: auth.token,
          userId: auth.user.id,
          userName: auth.user.username,
          userPhone: phone,
        );
        return auth;
      }
      throw ApiException(message: data['message'] ?? 'Registration failed');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Login with phone + otp for existing user
  /// Matches backend: POST /api/auth/login { phone, otp }
  Future<AuthResponse> login({
    required String phone,
    required String otp,
  }) async {
    try {
      final response =  await _apiService.dio.post(
        '/auth/login',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      final data =  response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final auth =  AuthResponse.fromBackendJson(data);
        await _session.saveSession(
          token: auth.token,
          userId: auth.user.id,
          userName: auth.user.username,
          userPhone: phone,
        );
        return auth;
      }
      throw ApiException(message: data['message'] ?? 'Login failed');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException.unauthorized();
      }
      if (e.response?.statusCode == 404) {
        throw ApiException(message: 'User not found. Please sign up first.');
      }
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Refresh token
  /// Matches backend: POST /api/auth/refresh-token { refreshToken }
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response =  await _apiService.dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      final data =  response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data']['token'] as String;
      }
      throw ApiException(message: 'Token refresh failed');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Logout
  /// Matches backend: POST /api/auth/logout
  Future<void> logout() async {
    try {
      final token =  _session.token.value;
      if (token != null && token.isNotEmpty) {
        await _apiService.dio.post(
          '/auth/logout',
          options: Options(headers: {
            'Authorization': 'Bearer $token',
          }),
        );
      }
    } on DioException {
      // Logout request may fail if token is invalid
    } finally {
      await _session.clearSession();
    }
  }

  /// Get current user from backend
  /// Matches backend: GET /api/auth/me
  Future<User> getCurrentUser() async {
    try {
      final response =  await _apiService.dio.get(
        '/auth/me',
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );

      final data =  response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return User.fromBackendJson(data['data']);
      }
      throw ApiException(message: 'Failed to fetch user');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Social Login (Google, Apple, Facebook, Snapchat, Instagram, Guest)
  /// Matches backend: POST /api/auth/social/login
  /// Sends Firebase ID Token — backend verifies server-side with Firebase Admin SDK
  Future<AuthResponse> socialLogin({
    required String provider,
    required String idToken,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/social/login',
        data: {
          'provider': provider,
          'idToken': idToken,
          if (deviceInfo != null) 'deviceInfo': deviceInfo,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final auth = AuthResponse.fromBackendJson(data);
        await _session.saveSession(
          token: auth.token,
          userId: auth.user.id,
          userName: auth.user.username,
          userEmail: auth.user.email ?? '',
          userAvatar: auth.user.avatar ?? '',
        );
        return auth;
      }
      throw ApiException(message: data['message'] ?? 'Social login failed');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Guest Login
  /// Matches backend: POST /api/auth/social/guest-login
  Future<AuthResponse> guestLogin({Map<String, dynamic>? deviceInfo}) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/social/guest-login',
        data: {
          if (deviceInfo != null) 'deviceInfo': deviceInfo,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final auth = AuthResponse.fromBackendJson(data);
        await _session.saveSession(
          token: auth.token,
          refreshTokenValue: auth.refreshToken,
          userId: auth.user.id,
          userName: auth.user.username,
          isGuest: true,
        );
        return auth;
      }
      throw ApiException(message: data['message'] ?? 'Guest login failed');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Get Active Sessions / Devices
  /// Matches backend: GET /api/security/devices/sessions
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      final response = await _apiService.dio.get(
        '/security/devices/sessions',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']['sessions'] ?? []);
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Get Login History
  /// Matches backend: GET /api/security/login-history
  Future<Map<String, dynamic>> getLoginHistory({int page = 1, int limit = 50}) async {
    try {
      final response = await _apiService.dio.get(
        '/security/login-history',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
        queryParameters: {'page': page, 'limit': limit},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data'];
      }
      return {'history': [], 'pagination': {}};
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Logout Device
  /// Matches backend: POST /api/security/devices/sessions/:sessionId/logout
  Future<bool> logoutDevice(String sessionId) async {
    try {
      final response = await _apiService.dio.post(
        '/security/devices/sessions/$sessionId/logout',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Trust Device
  /// Matches backend: POST /api/security/devices/sessions/:sessionId/trust
  Future<bool> trustDevice(String sessionId) async {
    try {
      final response = await _apiService.dio.post(
        '/security/devices/sessions/$sessionId/trust',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Forgot Password
  /// Matches backend: POST /api/security/forgot-password
  Future<bool> forgotPassword({String? email, String? phone}) async {
    try {
      final response = await _apiService.dio.post(
        '/security/forgot-password',
        data: {
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Get 2FA Status
  /// Matches backend: GET /api/security/2fa/status
  Future<Map<String, dynamic>> get2FAStatus() async {
    try {
      final response = await _apiService.dio.get(
        '/security/2fa/status',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data'];
      }
      return {};
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Enable 2FA
  /// Matches backend: POST /api/security/2fa/enable
  Future<Map<String, dynamic>> enable2FA({String method = 'totp', String? phone, String? email}) async {
    try {
      final response = await _apiService.dio.post(
        '/security/2fa/enable',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
        data: {
          'method': method,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data'];
      }
      throw ApiException(message: data['message'] ?? 'Failed to enable 2FA');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Verify and Enable 2FA
  /// Matches backend: POST /api/security/2fa/verify-enable
  Future<bool> verifyAndEnable2FA(String code) async {
    try {
      final response = await _apiService.dio.post(
        '/security/2fa/verify-enable',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
        data: {'code': code},
      );

      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Disable 2FA
  /// Matches backend: POST /api/security/2fa/disable
  Future<bool> disable2FA(String code) async {
    try {
      final response = await _apiService.dio.post(
        '/security/2fa/disable',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
        data: {'code': code},
      );

      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Get Suspicious Alerts
  /// Matches backend: GET /api/security/suspicious-alerts
  Future<List<Map<String, dynamic>>> getSuspiciousAlerts() async {
    try {
      final response = await _apiService.dio.get(
        '/security/suspicious-alerts',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']['alerts'] ?? []);
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Accept Terms & Privacy
  /// Matches backend: POST /api/security/terms/accept
  Future<bool> acceptTerms() async {
    try {
      final response = await _apiService.dio.post(
        '/security/terms/accept',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Setup Account Recovery
  /// Matches backend: POST /api/security/recovery/setup
  Future<bool> setupRecovery({String? recoveryEmail, String? recoveryPhone}) async {
    try {
      final response = await _apiService.dio.post(
        '/security/recovery/setup',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
        data: {
          if (recoveryEmail != null) 'recoveryEmail': recoveryEmail,
          if (recoveryPhone != null) 'recoveryPhone': recoveryPhone,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Convenience redirect to session manager
  Future<void> saveToken(String token) => _session.saveSession(token: token);
  String? getToken() => _session.token.value;
  void clearToken() => _session.clearSession();
  bool isLoggedIn() => _session.hasToken();
}
