import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/coin_seller_controller.dart';

/// Main dashboard for the logged-in Coin Dealer.
/// Shows their transaction history.
class CoinSellerHomeScreen extends GetView<CoinSellerController> {
  const CoinSellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Dashboard'),
        backgroundColor: const Color(0xFF15141F),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.to(() => const CoinSellerProfileScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => controller.loadDealerData(), // Refresh button
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.transactions.isEmpty) {
          return const Center(child: Text('No transactions yet.', style: TextStyle(color: Colors.grey)));
        }
        // Display the logged-in dealer's transaction history
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            final tx = controller.transactions[index];
            final isCredit = tx['type'] == 'dealer_transfer_in';
            return Card(
              color: const Color(0xFF1A1A2E),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCredit ? Colors.green.withValues(alpha: 50/255) : Colors.red.withValues(alpha: 50/255),
                  child: Icon(isCredit ? Icons.add : Icons.remove, color: isCredit ? Colors.green : Colors.red),
                ),
                title: Text(tx['description'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'To: ${(tx['metadata'] as Map<String, dynamic>?)?['targetUid'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: Text(
                  '${isCredit ? '+' : '-'}${tx['amount']} coins',
                  style: TextStyle(color: isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const TransferCoinsScreen()),
        backgroundColor: const Color(0xFFFF8906),
        tooltip: 'Transfer Coins',
        child: const Icon(Icons.send),
      ),
    );
  }
}

/// Screen for the dealer to transfer coins to a user.
class TransferCoinsScreen extends GetView<CoinSellerController> {
  const TransferCoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final targetUidCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Coins To User')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the recipient\'s User ID and the amount of coins you wish to send.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: targetUidCtrl,
              decoration: InputDecoration(
                labelText: 'Target User ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.person_search, color: Color(0xFFFF8906)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Coins',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.monetization_on, color: Color(0xFFFF8906)),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
              width: double.infinity,
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        final targetUid = targetUidCtrl.text;
                        final amount = int.tryParse(amountCtrl.text) ?? 0;
                        if (targetUid.isNotEmpty && amount > 0) {
                          final success = await controller.transferCoinsToUser(targetUid: targetUid, amount: amount);
                          if (success) {
                            Get.back(); // Go back to dashboard on success
                          }
                        } else {
                          Get.snackbar('Invalid Input', 'Please enter a valid User ID and amount.', backgroundColor: Colors.red);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906), padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Confirm & Transfer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
            )),
          ],
        ),
      ),
    );
  }
}


/// Shows the logged-in dealer's own profile and stats.
class CoinSellerProfileScreen extends GetView<CoinSellerController> {
  const CoinSellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Dealer Profile'), backgroundColor: const Color(0xFF15141F)),
      body: Obx(() {
        if (controller.isLoading.value && controller.dealerWallet.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final wallet = controller.dealerWallet.value;
        if (wallet == null) {
          return const Center(child: Text('Could not load dealer profile.', style: TextStyle(color: Colors.grey)));
        }
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: const Color(0xFF1A1A2E),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(radius: 40, backgroundColor: Colors.amber, child: Icon(Icons.store, color: Colors.black, size: 40)),
                        const SizedBox(height: 8),
                        Text(wallet['uid'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('${(wallet['level'] ?? '').toString().toUpperCase()} SELLER', style: const TextStyle(color: Colors.amber, fontSize: 14)),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                  _infoRow('Balance', '${(wallet['balance'] as num? ?? 0).toStringAsFixed(2)} Coins'),
                  _infoRow('Commission Rate', '${((wallet['commissionPercent'] as num? ?? 0) * 100).toStringAsFixed(1)}%'),
                  _infoRow('Max Transfer/Transaction', '${wallet['maxTransferPerTransaction'] ?? 0} Coins'),
                  _infoRow('Daily Transfer Limit', '${wallet['dailyTransferLimit'] ?? 0} Coins'),
                  _infoRow('Today\'s Transfers', '${wallet['currentDailyTransfer'] ?? 0} Coins'),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// NOTE: The other screens from the original file (Ranking, other histories) have been removed
// as they were based on a different data model (list of all sellers) which is not
// available to a dealer. They can be re-implemented if specific APIs exist for them.
