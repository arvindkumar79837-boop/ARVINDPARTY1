import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/coin_seller_controller.dart';

class CoinSellerProfileScreen extends StatelessWidget {
  const CoinSellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Coin Seller Profile', style: TextStyle(color: Colors.white, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => Get.find<CoinSellerController>().loadDealerData(),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final controller = Get.find<CoinSellerController>();
          if (controller.isLoading.value && controller.dealerWallet.value == null) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          final wallet = controller.dealerWallet.value;
          final uid = wallet?['uid'] ?? 'N/A';
          final balance = (wallet?['balance'] as num? ?? 0).toDouble();
          final level = wallet?['level'] ?? 'normal';
          final commission = ((wallet?['commissionPercent'] as num? ?? 0) * 100).toDouble();
          final maxPerTx = wallet?['maxTransferPerTransaction'] ?? 0;
          final dailyLimit = wallet?['dailyTransferLimit'] ?? 0;
          final todayUsed = wallet?['currentDailyTransfer'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(uid, level, balance),
                const SizedBox(height: 24),
                _buildWalletStats(balance, commission, maxPerTx, dailyLimit, todayUsed),
                const SizedBox(height: 24),
                _buildLimitsSection(maxPerTx, dailyLimit, todayUsed),
                const SizedBox(height: 24),
                _buildCommissionDetails(commission),
                const SizedBox(height: 24),
                _buildActivityLog(controller),
                const SizedBox(height: 80),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileHeader(String uid, String level, double balance) {
    final levelColor = level == 'official'
        ? Colors.amber
        : level == 'super'
            ? Colors.purple
            : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            levelColor.withValues(alpha: 0.2),
            levelColor.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: levelColor.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: levelColor.withValues(alpha: 0.2),
                child: Icon(Icons.store, color: levelColor, size: 45),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: levelColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A1A2E), width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(uid, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${level.toString().toUpperCase()} SELLER',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: levelColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$balance Coins',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text('Available Balance', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildWalletStats(double balance, double commission, dynamic maxPerTx, dynamic dailyLimit, dynamic todayUsed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Wallet Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _buildStatCard('Commission', '${commission.toStringAsFixed(1)}%', Colors.amber, Icons.percent),
            _buildStatCard('Total Sales', '₹24,500', Colors.green, Icons.trending_up),
            _buildStatCard('This Month', '₹8,200', Colors.blue, Icons.calendar_month),
            _buildStatCard('Pending', '₹1,500', Colors.orange, Icons.schedule),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Widget _buildLimitsSection(dynamic maxPerTx, dynamic dailyLimit, dynamic todayUsed) {
    final limit = (dailyLimit as num? ?? 0).toDouble();
    final used = (todayUsed as num? ?? 0).toDouble();
    final progress = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transfer Limits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Daily Limit Used', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                  Text('$used / $limit', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.8 ? Colors.red : progress > 0.5 ? Colors.orange : Colors.green,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),
              _buildLimitRow('Max per Transaction', '$maxPerTx coins', Icons.swap_horiz),
              const Divider(color: Colors.white10),
              _buildLimitRow('Daily Transfer Limit', '$limit coins', Icons.today),
              const Divider(color: Colors.white10),
              _buildLimitRow('Remaining Today', '${(limit - used).clamp(0, double.infinity).toInt()} coins', Icons.account_balance_wallet_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLimitRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCommissionDetails(double commission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Commission Structure', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _buildCommissionRow('Your Commission Rate', '${commission.toStringAsFixed(1)}%', true),
              const Divider(color: Colors.white10),
              _buildCommissionRow('Total Revenue Generated', '₹24,500', false),
              _buildCommissionRow('Commission Earned', '₹${(24500 * commission / 100).toStringAsFixed(2)}', false),
              _buildCommissionRow('Settled Amount', '₹18,200', false),
              _buildCommissionRow('Pending Settlement', '₹${(24500 * commission / 100 - 18200).clamp(0, double.infinity).toStringAsFixed(2)}', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionRow(String label, String value, bool isHighlight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? Colors.amber : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLog(CoinSellerController controller) {
    final txns = controller.transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transfers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.coinSellerTransactions);
              },
              child: Text('View All', style: TextStyle(fontSize: 12, color: Colors.amber.withValues(alpha: 0.8))),
            ),
          ],
        ),
        if (txns.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text('No recent transfers', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
            ),
          )
        else
          ...txns.map((tx) {
            final isCredit = tx['type'] == 'dealer_transfer_in';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCredit ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(isCredit ? Icons.add : Icons.remove, color: isCredit ? Colors.green : Colors.red, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx['description'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.white)),
                        Text(
                          'To: ${(tx['metadata'] as Map<String, dynamic>?)?['targetUid'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isCredit ? '+' : '-'}${tx['amount']} coins',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isCredit ? Colors.green : Colors.red),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
