// ═══════════════════════════════════════════════════════════════════════════
// VIEW: CoinOrdersView — Coin order history
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class CoinOrdersView extends StatefulWidget {
  const CoinOrdersView({super.key});

  @override
  State<CoinOrdersView> createState() => _CoinOrdersViewState();
}

class _CoinOrdersViewState extends State<CoinOrdersView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/coin-orders');
      if (response['success'] == true) {
        _orders = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final canView = _permService.hasPermission('coin_orders.view');
    if (!canView) {
      return const Scaffold(body: Center(child: Text('Permission denied')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Coin Orders')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (ctx, i) {
                    final order = _orders[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long, color: Colors.green),
                        title: Text('Order: ${order['_id']?.substring(0, 8) ?? ''}'),
                        subtitle: Text('Seller: ${order['sellerUid'] ?? ''} | Amount: ${order['amount'] ?? 0} | ${order['status'] ?? ''}'),
                        trailing: Text(order['status'] ?? '', style: TextStyle(color: order['status'] == 'completed' ? Colors.green : Colors.orange)),
                      ),
                    );
                  },
                ),
    );
  }
}