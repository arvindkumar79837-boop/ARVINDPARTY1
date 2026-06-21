// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/views/device_binding_screen.dart
// ARVIND PARTY - DEVICE BINDING SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/device_binding_controller.dart';

class DeviceBindingScreen extends StatelessWidget {
  const DeviceBindingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DeviceBindingController controller = Get.put(DeviceBindingController());

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Device Binding',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildCurrentDeviceCard(controller),
              const SizedBox(height: 24),
              _buildBoundDevicesSection(controller),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        if (!controller.isCurrentDeviceBound.value) {
          return FloatingActionButton.extended(
            onPressed: controller.bindCurrentDevice,
            backgroundColor: const Color(0xFF1E88E5),
            icon: const Icon(Icons.link, color: Colors.white),
            label: const Text(
              'Bind This Device',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E88E5).withValues(alpha: 0.15),
            const Color(0xFF1E88E5).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF64B5F6),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'About Device Binding',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Bind up to ${DeviceBindingController.maxAllowedDevices} devices to your account for enhanced security. You can manage and remove devices anytime.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDeviceCard(DeviceBindingController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: controller.isCurrentDeviceBound.value
              ? Colors.green.withValues(alpha: 0.5)
              : Colors.orange.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Device',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: controller.isCurrentDeviceBound.value
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      controller.isCurrentDeviceBound.value
                          ? Icons.check_circle
                          : Icons.warning,
                      size: 14,
                      color: controller.isCurrentDeviceBound.value
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Obx(() => Text(
                          controller.isCurrentDeviceBound.value ? 'Bound' : 'Not Bound',
                          style: TextStyle(
                            fontSize: 12,
                            color: controller.isCurrentDeviceBound.value
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => _buildDeviceInfoRow(
                icon: Icons.devices,
                label: 'Device',
                value: controller.deviceModel.value.isEmpty
                    ? 'Detecting...'
                    : '${controller.deviceName.value} (${controller.deviceModel.value})',
              )),
          Obx(() => _buildDeviceInfoRow(
                icon: Icons.devices,
                label: 'Platform',
                value: controller.devicePlatform.value.isEmpty
                    ? 'Detecting...'
                    : controller.getDevicePlatformIcon(controller.devicePlatform.value),
              )),
          Obx(() => _buildDeviceInfoRow(
                icon: Icons.public,
                label: 'OS',
                value: controller.deviceOsVersion.value.isEmpty
                    ? 'Detecting...'
                    : controller.deviceOsVersion.value,
              )),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64B5F6)),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoundDevicesSection(DeviceBindingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bound Devices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Obx(() => Text(
                  '${controller.boundDevices.length}/${DeviceBindingController.maxAllowedDevices}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                  color: Color(0xFF1E88E5),
                ),
              ),
            );
          }

          if (controller.boundDevices.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.devices_other,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No devices bound yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.boundDevices.length,
            itemBuilder: (context, index) {
              final device = controller.boundDevices[index];
              final isCurrent = device['isCurrentDevice'] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFF1E88E5).withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFF1E88E5).withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        controller.getDevicePlatformIcon(device['devicePlatform'] ?? ''),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device['deviceName'] ?? 'Unknown Device',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            device['deviceModel'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (device['boundAt'] != null)
                            Text(
                              'Bound: ${controller.formatBoundDate(device['boundAt'])}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!isCurrent)
                      IconButton(
                        onPressed: () => _showUnbindDialog(controller, device['deviceId']),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.withValues(alpha: 0.7),
                          size: 20,
                        ),
                        tooltip: 'Unbind Device',
                      ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showUnbindDialog(
    DeviceBindingController controller,
    String deviceId,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Unbind Device?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This device will no longer have access to your account. Are you sure?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.unbindDevice(deviceId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Unbind',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}