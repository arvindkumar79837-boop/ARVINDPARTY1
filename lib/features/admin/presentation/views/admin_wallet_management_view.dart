// ═══════════════════════════════════════════════════════════════════════════
// VIEW: AdminWalletManagementView — Admin wallet overview & adjustments
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminWalletManagementView extends StatelessWidget {
  const AdminWalletManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Adjust User Wallet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),

            // User ID
            _buildTextField(
              label: 'User ID',
              hint: 'Enter user ID (e.g. USR...)',
              onChanged: (v) => ctrl.walletUserId.value = v,
              validator: ctrl.validateWalletUserId,
            ),
            const SizedBox(height: 12),

            // Amount
            _buildTextField(
              label: 'Amount',
              hint: 'Enter amount',
              keyboardType: TextInputType.number,
              onChanged: (v) => ctrl.walletAmount.value = v,
              validator: ctrl.validateWalletAmount,
            ),
            const SizedBox(height: 12),

            // Type selector
            Obx(() => Row(
              children: [
                const Text('Type:', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                _buildChoiceChip('Coins', ctrl.walletType.value == 'coins', () {
                  ctrl.walletType.value = 'coins';
                }),
                const SizedBox(width: 8),
                _buildChoiceChip('Diamonds', ctrl.walletType.value == 'diamonds', () {
                  ctrl.walletType.value = 'diamonds';
                }),
              ],
            )),
            const SizedBox(height: 12),

            // Action selector
            Obx(() => Row(
              children: [
                const Text('Action:', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                _buildChoiceChip('Add', ctrl.walletAction.value == 'add', () {
                  ctrl.walletAction.value = 'add';
                }),
                const SizedBox(width: 8),
                _buildChoiceChip('Deduct', ctrl.walletAction.value == 'deduct', () {
                  ctrl.walletAction.value = 'deduct';
                }),
              ],
            )),
            const SizedBox(height: 24),

            // Submit button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ctrl.isLoading.value ? null : () => ctrl.adjustWallet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8906),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: ctrl.isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        ctrl.walletAction.value == 'add' ? 'Add Coins' : 'Deduct Coins',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            )),
            const SizedBox(height: 32),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),

            // Withdrawals Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pending Withdrawals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  onPressed: () => ctrl.loadWithdrawals(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (ctrl.isLoading.value && ctrl.withdrawals.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (ctrl.withdrawals.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No pending withdrawals', style: TextStyle(color: Colors.white54)),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ctrl.withdrawals.length,
                itemBuilder: (context, index) {
                  final w = ctrl.withdrawals[index];
                  final status = w['status'] ?? 'pending';
                  return Card(
                    color: const Color(0xFF1E1E2E),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        '${w['userName'] ?? w['userId'] ?? 'Unknown'} - ${w['amount'] ?? 0} coins',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Status: $status',
                        style: TextStyle(
                          color: status == 'approved'
                              ? Colors.greenAccent
                              : status == 'rejected'
                                  ? Colors.redAccent
                                  : Colors.orangeAccent,
                        ),
                      ),
                      trailing: status == 'pending'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                                  onPressed: () => ctrl.processWithdrawal(w['_id'] ?? w['id'], 'approved'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.redAccent),
                                  onPressed: () => ctrl.processWithdrawal(w['_id'] ?? w['id'], 'rejected'),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
    String? Function(String)? validator,
  }) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: const Color(0xFF1E1E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF8906)),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF8906) : const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFFF8906) : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
