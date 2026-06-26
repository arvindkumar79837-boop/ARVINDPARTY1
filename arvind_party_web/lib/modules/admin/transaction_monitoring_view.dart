// ═══════════════════════════════════════════════════════════════════════════
// MODULE: Admin Transaction Monitoring Dashboard
// ARVIND PARTY - Web Admin Panel
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class TransactionMonitoringView extends GetView<TransactionMonitoringController> {
  const TransactionMonitoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Monitoring'),
        backgroundColor: Colors.green[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadTransactions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.transactions.isEmpty) {
                return const Center(child: Text('No transactions found', style: TextStyle(color: Colors.grey)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) => _buildTransactionCard(controller.transactions[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green[50],
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: controller.filterType.value,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Types')),
                DropdownMenuItem(value: 'credit', child: Text('Credit')),
                DropdownMenuItem(value: 'debit', child: Text('Debit')),
              ],
              onChanged: (value) {
                if (value != null) controller.filterType.value = value;
                controller.loadTransactions();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: controller.filterStatus.value,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Status')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'failed', child: Text('Failed')),
              ],
              onChanged: (value) {
                if (value != null) controller.filterStatus.value = value;
                controller.loadTransactions();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final txId = transaction['_id'] ?? '';
    final userId = transaction['userId'] ?? '';
    final userName = transaction['userName'] ?? 'Unknown';
    final type = transaction['type'] ?? 'unknown';
    final amount = transaction['amount'] ?? 0;
    final currency = transaction['currency'] ?? 'coins';
    final status = transaction['status'] ?? 'pending';
    final description = transaction['description'] ?? '';
    final createdAt = transaction['createdAt'] != null 
        ? DateTime.parse(transaction['createdAt']).toString().split(' ')[0]
        : 'N/A';

    final isCredit = type == 'credit';
    final statusColor = status == 'completed' ? Colors.green : status == 'pending' ? Colors.orange : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit ? Colors.green[100] : Colors.red[100],
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          '${isCredit ? "Credit" : "Debit"} - $currency',
          style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: $userName | Amount: $amount'),
            Text('$description | $createdAt | Status: ${status.toUpperCase()}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              (isCredit ? '+' : '-') + '$amount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor),
            ),
            Text(status, style: TextStyle(fontSize: 10, color: statusColor)),
          ],
        ),
      ),
    );
  }
}

class TransactionMonitoringController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString filterType = 'all'.obs;
  final RxString filterStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    isLoading.value = true;
    try {
      String endpoint = '/api/admin/transactions?type=${filterType.value}&status=${filterStatus.value}';
      final response = await _api.get(endpoint);
      if (response['success'] == true) {
        final data = response['data'] as List;
        transactions.assignAll(data.map((e) => Map<String, dynamic>.from(e)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}