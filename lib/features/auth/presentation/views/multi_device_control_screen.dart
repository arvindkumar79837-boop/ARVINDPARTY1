// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/views/multi_device_control_screen.dart
// ARVIND PARTY - MULTI-DEVICE CONTROL SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/device_binding_controller.dart';

class MultiDeviceControlScreen extends StatelessWidget {
  const MultiDeviceControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeviceBindingController());

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
          'Multi-Device Control',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(controller),
              const SizedBox(height: 24),
              _buildDeviceListSection(controller),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(DeviceBindingController controller) {
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
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.device_hub,
                color: Color(0xFF64B5F6),
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Device Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                icon: Icons.devices,
                label: 'Active Devices',
                value: '${controller.boundDevices.length}',
                color: Colors.green,
              ),
              _buildStatItem(
                icon: Icons.lock,
                label: 'Current Device',
                value: controller.isCurrentDeviceBound.value ? 'Bound' : 'Unbound',
                color: controller.isCurrentDeviceBound.value ? Colors.green : Colors.orange,
              ),
              _buildStatItem(
                icon: Icons.warning,
                label: 'Max Allowed',
                value: '${DeviceBindingController.maxAllowedDevices}',
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDeviceListSection(DeviceBindingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'All Devices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              onPressed: controller.refreshDeviceList,
              icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF64B5F6)),
              label: const Text(
                'Refresh',
                style: TextStyle(
                  color: Color(0xFF64B5F6),
                  fontSize: 13,
                ),
              ),
            ),
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
                      'No devices found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bind your first device to get started',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              controller.getDevicePlatformIcon(device['devicePlatform'] ?? ''),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      device['deviceName'] ?? 'Unknown Device',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (isCurrent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: const Text(
                                        'Current',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                device['deviceModel'] ?? 'Unknown Model',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.public,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          device['devicePlatform'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Bound: ${controller.formatBoundDate(device['boundAt'])}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() {
                          final status = device['deviceId'] == controller.deviceId.value
                              ? 'Active'
                              : 'Inactive';
                          final statusColor = status == 'Active' ? Colors.green : Colors.grey;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  status == 'Active' ? Icons.circle : Icons.circle_outlined,
                                  size: 8,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (!isCurrent)
                          TextButton.icon(
                            onPressed: () => _showDeviceOptions(controller, device),
                            icon: Icon(
                              Icons.more_vert,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            label: Text(
                              'Manage',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                      ],
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

  void _showDeviceOptions(
    DeviceBindingController controller,
    Map<String, dynamic> device,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A3E),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              device['deviceName'] ?? 'Unknown Device',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.white.withValues(alpha: 0.7)),
              title: const Text('View Details', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                _showDeviceDetails(controller, device);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.withValues(alpha: 0.8)),
              title: const Text('Unbind Device', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _showUnbindConfirmDialog(controller, device['deviceId']);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showDeviceDetails(
    DeviceBindingController controller,
    Map<String, dynamic> device,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Device Details',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Device Name', device['deviceName'] ?? 'Unknown'),
            _detailRow('Model', device['deviceModel'] ?? 'Unknown'),
            _detailRow('Platform', device['devicePlatform'] ?? 'Unknown'),
            _detailRow('OS Version', device['deviceOsVersion'] ?? 'Unknown'),
            _detailRow('Bound Date', controller.formatBoundDate(device['boundAt'])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showUnbindConfirmDialog(
    DeviceBindingController controller,
    String? deviceId,
  ) {
    if (deviceId == null) return;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Unbind Device?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This device will lose access to your account. You can re-bind it later.',
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