// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/controllers/device_binding_controller.dart
// ARVIND PARTY - DEVICE BINDING CONTROLLER
// Manages unique device IDs and device registration
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import '../repositories/auth_repository.dart';

class DeviceBindingController extends GetxController {
  final authRepository = AuthRepository();
  final storage = GetStorage();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  // Device information
  var deviceId = ''.obs;
  var deviceName = ''.obs;
  var deviceModel = ''.obs;
  var devicePlatform = ''.obs;
  var deviceOsVersion = ''.obs;
  var appVersion = ''.obs;

  // Bound devices list
  var boundDevices = <Map<String, dynamic>>[].obs;
  var isDeviceBound = false.obs;
  var isCurrentDeviceBound = false.obs;

  // Maximum allowed devices
  static const int maxAllowedDevices = 3;

  @override
  void onInit() {
    super.onInit();
    _initializeDeviceInfo();
    checkDeviceBindingStatus();
    fetchBoundDevices();
  }

  Future<void> _initializeDeviceInfo() async {
    try {
      // Read persisted device ID first
      final savedDeviceId = storage.read('persistent_device_id');
      if (savedDeviceId != null) {
        deviceId.value = savedDeviceId;
      } else {
        // Generate a stable, persistent device ID
        try {
          final deviceInfo = DeviceInfoPlugin();
          if (kIsWeb) {
            deviceId.value = 'web_${DateTime.now().millisecondsSinceEpoch}';
          } else if (Platform.isAndroid) {
            final info = await deviceInfo.androidInfo;
            deviceId.value = info.id;
          } else if (Platform.isIOS) {
            final info = await deviceInfo.iosInfo;
            deviceId.value = info.identifierForVendor ?? 'ios_${DateTime.now().millisecondsSinceEpoch}';
          } else {
            deviceId.value = 'device_${DateTime.now().millisecondsSinceEpoch}';
          }
        } catch (_) {
          deviceId.value = 'device_${DateTime.now().millisecondsSinceEpoch}';
        }
        await storage.write('persistent_device_id', deviceId.value);
      }

      deviceName.value = 'Unknown Device';
      deviceModel.value = 'Unknown';
      devicePlatform.value = kIsWeb ? 'web' : 'mobile';
      deviceOsVersion.value = 'Unknown';

      // Check if device was previously bound
      final savedBoundId = storage.read('bound_device_id');
      if (savedBoundId != null && savedBoundId == deviceId.value) {
        isCurrentDeviceBound.value = true;
      }

      // Check stored device list
      final storedDevices = storage.read('bound_devices');
      if (storedDevices != null && storedDevices is List) {
        boundDevices.value = List<Map<String, dynamic>>.from(storedDevices);
      }
    } catch (e) {
      errorMessage.value = 'Failed to get device info: ${e.toString()}';
    }
  }

  void checkDeviceBindingStatus() {
    final devices = storage.read('bound_devices');
    if (devices != null) {
      final storedDevices = List<Map<String, dynamic>>.from(devices as List);
      isDeviceBound.value = storedDevices.any((d) => d['deviceId'] == deviceId.value);
    }
  }

  Future<void> fetchBoundDevices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final authRepo = AuthRepository();
      try {
        final response = await authRepo.getBoundDevices();
        if (response is Map && response['success'] == true) {
          final devices = response['devices'];
          if (devices is List) {
            boundDevices.value = List<Map<String, dynamic>>.from(devices);
            await _saveDevicesLocally(boundDevices);
          }
        }
      } catch (_) {
        // Backend API may not be available yet — fall back to local data
        debugPrint('fetchBoundDevices: backend unavailable, using local cache');
      }

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Failed to fetch devices: ${e.toString()}';
      isLoading.value = false;
    }
  }

  Future<void> bindCurrentDevice() async {
    if (isCurrentDeviceBound.value) {
      Get.snackbar(
        'Info',
        'This device is already bound to your account',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (boundDevices.length >= maxAllowedDevices) {
      Get.snackbar(
        'Device Limit Reached',
        'You can bind maximum $maxAllowedDevices devices. Please unbind an existing device first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final deviceData = {
        'deviceId': deviceId.value,
        'deviceName': deviceName.value,
        'deviceModel': deviceModel.value,
        'devicePlatform': devicePlatform.value,
        'deviceOsVersion': deviceOsVersion.value,
        'appVersion': appVersion.value,
        'boundAt': DateTime.now().toIso8601String(),
        'isCurrentDevice': true,
      };

      // Bind locally (backend API pending)
      boundDevices.add(deviceData);
      await _saveDevicesLocally(boundDevices);

      isDeviceBound.value = true;
      isCurrentDeviceBound.value = true;
      await storage.write('bound_device_id', deviceId.value);

      Get.snackbar(
        'Success',
        'Device bound successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to bind device: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unbindDevice(String deviceIdToRemove) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      // Unbind locally (backend API pending)
      boundDevices.removeWhere((device) => device['deviceId'] == deviceIdToRemove);
      await _saveDevicesLocally(boundDevices);

      if (deviceIdToRemove == deviceId.value) {
        isCurrentDeviceBound.value = false;
        isDeviceBound.value = false;
        await storage.remove('bound_device_id');
      }

      Get.snackbar(
        'Success',
        'Device unbound successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to unbind device: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String getDevicePlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return '🤖';
      case 'ios':
        return '📱';
      case 'web':
        return '🌐';
      case 'windows':
        return '🖥️';
      case 'macos':
        return '💻';
      default:
        return '📱';
    }
  }

  String formatBoundDate(String? isoDate) {
    if (isoDate == null) return 'Unknown';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _saveDevicesLocally(List<Map<String, dynamic>> devices) async {
    await storage.write('bound_devices', devices);
  }

  Future<bool> isDeviceAllowed() async {
    await _initializeDeviceInfo();
    if (isCurrentDeviceBound.value) return true;

    final count = boundDevices.length;
    return count < maxAllowedDevices;
  }

  void refreshDeviceList() {
    checkDeviceBindingStatus();
    fetchBoundDevices();
  }

}