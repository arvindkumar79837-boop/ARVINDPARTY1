// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/views/wallet_hub_screen.dart
// ARVIND PARTY - WALLET HUB SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'coin_wallet_screen.dart';
import 'diamond_wallet_screen.dart';
import 'placeholder_wallet_screen.dart';
import 'reward_wallet_screen.dart';

class WalletHubScreen extends StatelessWidget {
  const WalletHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallets = [
      _WalletItem(name: 'Coin Wallet', icon: Icons.monetization_on, onTap: () => Get.to(() => const CoinWalletScreen())),
      _WalletItem(name: 'Diamond Wallet', icon: Icons.diamond, onTap: () => Get.to(() => const DiamondWalletScreen())),
      _WalletItem(name: 'Reward Wallet', icon: Icons.star, onTap: () => Get.to(() => const RewardWalletScreen())),
      _WalletItem(name: 'Agency Wallet', icon: Icons.business_center, onTap: () => Get.to(() => const PlaceholderWalletScreen(title: 'Agency Wallet'))),
      _WalletItem(name: 'Family Wallet', icon: Icons.family_restroom, onTap: () => Get.to(() => const PlaceholderWalletScreen(title: 'Family Wallet'))),
      _WalletItem(name: 'Commission Wallet', icon: Icons.percent, onTap: () => Get.to(() => const PlaceholderWalletScreen(title: 'Commission Wallet'))),
      _WalletItem(name: 'Cashback Wallet', icon: Icons.receipt_long, onTap: () => Get.to(() => const PlaceholderWalletScreen(title: 'Cashback Wallet'))),
    ];

    final otherFeatures = [
      _FeatureItem(name: 'Recharge History', icon: Icons.history, onTap: () => Get.to(() => const PlaceholderWalletScreen(title: 'Recharge History'))),
      _FeatureItem(name: 'Withdraw History', icon: Icons.history_edu, onTap: () => Get.to(() => const PlaceholderWalletScreen(title: 'Withdraw History'))),
      _FeatureItem(name: 'Wallet Logs', icon: Icons.list_alt, onTap: () => Get.to(() => const PlaceholderWalletScreen(title: 'Wallet Logs'))),
      _FeatureItem(name: 'Daily Income', icon: Icons.today, onTap: () => Get.to(() => const PlaceholderWalletScreen(title: 'Daily Income'))),
      _FeatureItem(name: 'Monthly Income', icon: Icons.calendar_month, onTap: () => Get.to(() => const PlaceholderWalletScreen(title: 'Monthly Income'))),
      _FeatureItem(name: 'Tax Report', icon: Icons.assessment, onTap: () => Get.to(() => const PlaceholderWalletScreen(title: 'Tax Report'))),
      _FeatureItem(name: 'Wallet Freeze', icon: Icons.lock, onTap: () => Get.to(() => const PlaceholderWalletScreen(title: 'Wallet Freeze'))),
      _FeatureItem(name: 'Wallet Audit', icon: Icons.security, onTap: () => Get.to(() => const PlaceholderWalletScreen(title: 'Wallet Audit'))),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Hub'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Wallets',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wallets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                return _buildWalletCard(wallets[index]);
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Other Features',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: otherFeatures.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return _buildFeatureTile(otherFeatures[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(_WalletItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(item.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(_FeatureItem item) {
    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.name),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: item.onTap,
    );
  }
}

class _WalletItem {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  _WalletItem({required this.name, required this.icon, required this.onTap});
}

class _FeatureItem {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  _FeatureItem({required this.name, required this.icon, required this.onTap});
}
