// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/views/withdrawal_management_view.dart
// ARVIND PARTY - ADMIN WITHDRAWAL MANAGEMENT VIEW
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service.dart';
import '../controllers/withdrawal_controller.dart';

class WithdrawalManagementView extends StatelessWidget {
  const WithdrawalManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WithdrawalController());

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
          'Withdrawal Management',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => controller.fetchWithdrawalHistory(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatsOverview(controller),
            _buildFilterTabs(controller),
            Expanded(child: _buildWithdrawalList(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(WithdrawalController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.withValues(alpha: 0.2),
            Colors.deepPurple.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
      ),
      child: Obx(() {
        return Row(
          children: [
            Expanded(child: _buildStatColumn('Pending', controller.pendingCount.value, Colors.orange)),
            Expanded(child: _buildStatColumn('Approved', controller.approvedCount.value, Colors.green)),
            Expanded(child: _buildStatColumn('Rejected', controller.rejectedCount.value, Colors.red)),
          ],
        );
      }),
    );
  }

  Widget _buildStatColumn(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
      ],
    );
  }

  Widget _buildFilterTabs(WithdrawalController controller) {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'PENDING', 'label': 'Pending'},
      {'key': 'APPROVED', 'label': 'Approved'},
      {'key': 'REJECTED', 'label': 'Rejected'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final f = filters[index];
            return Obx(() {
              final key = f['key']!;
              final isActive = controller.selectedFilter.value == key ||
                  (controller.selectedFilter.value == 'all' && key == 'all');
              final activeFilter = controller.selectedFilter.value;
              final isSelected = key == 'all' ? activeFilter == 'all' : activeFilter == key;

              return GestureDetector(
                onTap: () => controller.selectedFilter.value = key,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.indigo.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? Colors.indigo : Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    f['label']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.indigo : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildWithdrawalList(WithdrawalController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Colors.indigo));
      }

      final items = controller.filteredHistory;
      if (items.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 56, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Text('No withdrawal requests', style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.5))),
                const SizedBox(height: 8),
                Text('All clear!', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.35))),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.fetchWithdrawalHistory(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildWithdrawalItem(items[index], controller),
        ),
      );
    });
  }

  Widget _buildWithdrawalItem(Map<String, dynamic> item, WithdrawalController controller) {
    final status = item['status'] ?? 'PENDING';
    final amount = item['amount'] ?? 0;
    final diamonds = item['diamonds'] ?? 0;
    final method = item['method'] ?? 'N/A';
    final createdAt = item['createdAt'] != null ? DateTime.tryParse(item['createdAt']) : null;
    final userName = item['userName'] ?? item['uid'] ?? 'Unknown';
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: statusColor.withValues(alpha: 0.15),
                child: Icon(_getStatusIcon(status), color: statusColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 2),
                    if (createdAt != null)
                      Text(_formatDate(createdAt), style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildDetailChip(Icons.monetization_on_outlined, '$diamonds diamonds', Colors.cyan),
              const SizedBox(width: 8),
              _buildDetailChip(Icons.money_outlined, '₹$amount', Colors.green),
              const SizedBox(width: 8),
              _buildDetailChip(Icons.payment_outlined, method, Colors.purple),
            ],
          ),
          if (status == 'PENDING') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _handleApprove(item['_id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Approve', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _handleReject(item['_id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reject', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  Future<void> _handleApprove(String id) async {
    Get.defaultDialog(
      title: 'Approve Withdrawal',
      titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
      backgroundColor: const Color(0xFF1A1A2E),
      content: const Text('Are you sure you want to approve this withdrawal?', style: TextStyle(color: Colors.white70)),
      confirm: ElevatedButton(
        onPressed: () async {
          Get.back();
          try {
            final api = Get.find<ApiService>();
            await api.put('/api/wallet/admin/withdrawals/$id/approve', body: {});
            Get.snackbar('Approved', 'Withdrawal approved successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withValues(alpha: 0.8),
                colorText: Colors.white);
            if (Get.isRegistered<WithdrawalController>()) {
              Get.find<WithdrawalController>().fetchWithdrawalHistory();
            }
          } catch (e) {
            Get.snackbar('Error', 'Failed to approve: $e',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withValues(alpha: 0.8),
                colorText: Colors.white);
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text('Confirm', style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }

  Future<void> _handleReject(String id) async {
    Get.defaultDialog(
      title: 'Reject Withdrawal',
      titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
      backgroundColor: const Color(0xFF1A1A2E),
      content: const Text('Are you sure you want to reject this withdrawal?', style: TextStyle(color: Colors.white70)),
      confirm: ElevatedButton(
        onPressed: () async {
          Get.back();
          try {
            final api = Get.find<ApiService>();
            await api.put('/api/wallet/admin/withdrawals/$id/reject', body: {});
            Get.snackbar('Rejected', 'Withdrawal rejected',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withValues(alpha: 0.8),
                colorText: Colors.white);
            if (Get.isRegistered<WithdrawalController>()) {
              Get.find<WithdrawalController>().fetchWithdrawalHistory();
            }
          } catch (e) {
            Get.snackbar('Error', 'Failed to reject: $e',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withValues(alpha: 0.8),
                colorText: Colors.white);
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text('Reject', style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
      case 'PAID':
        return Colors.green;
      case 'PENDING':
      case 'PROCESSING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.white70;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'APPROVED':
      case 'PAID':
        return Icons.check_circle_outline;
      case 'PENDING':
      case 'PROCESSING':
        return Icons.hourglass_top_outlined;
      case 'REJECTED':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
