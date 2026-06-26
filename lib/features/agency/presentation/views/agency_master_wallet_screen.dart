import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencyMasterWalletScreen extends StatelessWidget {
  const AgencyMasterWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgencyController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agency Master Wallet'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Host Dashboard'),
              Tab(text: 'Owner Dashboard'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _HostDashboard(controller: controller),
            _OwnerDashboard(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _HostDashboard extends StatefulWidget {
  final AgencyController controller;
  const _HostDashboard({required this.controller});

  @override
  State<_HostDashboard> createState() => _HostDashboardState();
}

class _HostDashboardState extends State<_HostDashboard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: widget.controller.getHostAgencyDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('No agency data available'));
        }
        final data = snapshot.data!;
        final agency = data['agency'] as Map<String, dynamic>?;
        final host = data['host'] as Map<String, dynamic>?;
        final currentMonth = data['currentMonth'] as Map<String, dynamic>?;
        final wallet = data['wallet'] as Map<String, dynamic>?;

        return RefreshIndicator(
          onRefresh: () async {
            await widget.controller.getHostAgencyDashboard();
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (agency != null) _buildAgencyCard(agency),
              const SizedBox(height: 16),
              if (host != null) _buildHostCard(host),
              const SizedBox(height: 16),
              if (currentMonth != null) _buildMonthlyTargetCard(currentMonth),
              const SizedBox(height: 16),
              if (wallet != null) _buildWalletCard(wallet),
              const SizedBox(height: 16),
              _buildEarningsBreakdown(currentMonth),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgencyCard(Map<String, dynamic> agency) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              agency['name'] ?? 'Agency',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total Hosts: ${agency['totalHosts'] ?? 0}'),
            Text('Commission Rate: ${((agency['commissionRate'] ?? 0.1) * 100).toInt()}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildHostCard(Map<String, dynamic> host) {
    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              host['name'] ?? 'Host',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Coins: ${host['coins'] ?? 0}'),
                Text('Diamonds: ${host['diamonds'] ?? 0}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTargetCard(Map<String, dynamic> month) {
    final targetCoins = month['targetCoins'] ?? 0;
    final earningsDiamonds = month['earningsDiamonds'] ?? 0;
    final targetReward = month['targetReward'] ?? 0;

    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Month Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildProgressRow('Target Coins', targetCoins.toDouble(), 10000),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Earnings: $earningsDiamonds diamonds'),
                Text(
                  'Reward: \$$targetReward',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, double current, double target) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${current.toInt()} / ${target.toInt()}'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildWalletCard(Map<String, dynamic> wallet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agency Wallet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildWalletRow('Balance', wallet['agencyBalance'] ?? 0),
            _buildWalletRow('Pending Withdrawal', wallet['agencyPendingWithdrawal'] ?? 0),
            _buildWalletRow('Total Earnings', wallet['agencyTotalEarnings'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdown(Map<String, dynamic>? month) {
    if (month == null) return const SizedBox.shrink();
    final earningsDiamonds = month['earningsDiamonds'] ?? 0;
    final commissionToOwner = month['commissionToOwner'] ?? 0;
    final giftsReceived = month['giftsReceived'] ?? 0;
    final agencyTotalEarnings = month['agencyTotalEarnings'] ?? 0;
    final agencyTotalCommission = month['agencyTotalCommission'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Your Earnings (Diamonds)', earningsDiamonds.toString()),
            _buildSummaryRow('Commission to Owner', commissionToOwner.toString()),
            _buildSummaryRow('Gifts Received', giftsReceived.toString()),
            const Divider(),
            _buildSummaryRow('Agency Total Earnings', agencyTotalEarnings.toString(), isBold: true),
            _buildSummaryRow('Agency Total Commission', agencyTotalCommission.toString(), isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}

class _OwnerDashboard extends StatefulWidget {
  final AgencyController controller;
  const _OwnerDashboard({required this.controller});

  @override
  State<_OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<_OwnerDashboard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: widget.controller.getOwnerAgencyDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('No agency data available'));
        }
        final data = snapshot.data!;
        final agency = data['agency'] as Map<String, dynamic>?;
        final hosts = data['hosts'] as List<dynamic>? ?? [];
        final currentMonth = data['currentMonth'] as Map<String, dynamic>?;
        final lastMonth = data['lastMonth'] as Map<String, dynamic>?;
        final twoMonthsAgo = data['twoMonthsAgo'] as Map<String, dynamic>?;
        final wallet = data['wallet'] as Map<String, dynamic>?;

        return RefreshIndicator(
          onRefresh: () async {
            await widget.controller.getOwnerAgencyDashboard();
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (agency != null) _buildAgencyHeader(agency),
              const SizedBox(height: 16),
              _buildMonthlyTotalsCard(currentMonth, lastMonth, twoMonthsAgo),
              const SizedBox(height: 16),
              if (wallet != null) _buildWalletCard(wallet),
              const SizedBox(height: 16),
              const Text(
                'Hosts Performance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...hosts.map((host) => _HostTile(host: host as Map<String, dynamic>)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgencyHeader(Map<String, dynamic> agency) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              agency['name'] ?? 'Agency',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total Hosts: ${agency['totalHosts'] ?? 0}'),
            Text('Commission Rate: ${((agency['commissionRate'] ?? 0.1) * 100).toInt()}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTotalsCard(Map<String, dynamic>? current, Map<String, dynamic>? last, Map<String, dynamic>? twoMonthsAgo) {
    return Card(
      color: Colors.purple.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Global Agency Totals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMonthSection('Current Month', current),
            const SizedBox(height: 12),
            _buildMonthSection('Last Month', last),
            const SizedBox(height: 12),
            _buildMonthSection('2 Months Ago', twoMonthsAgo),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSection(String label, Map<String, dynamic>? month) {
    if (month == null) return const SizedBox.shrink();
    final targetCoins = month['totalHostTargetCoins'] ?? 0;
    final hostEarnings = month['totalHostEarningsDiamonds'] ?? 0;
    final ownerCommission = month['ownerCommissionDiamonds'] ?? 0;
    final activeHosts = month['activeHostsCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Target: $targetCoins coins')),
              Expanded(child: Text('Earnings: $hostEarnings')),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Commission: $ownerCommission')),
              Expanded(child: Text('Active Hosts: $activeHosts')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(Map<String, dynamic> wallet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agency Wallet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildWalletRow('Balance', wallet['balance'] ?? 0),
            _buildWalletRow('Pending Withdrawal', wallet['pendingWithdrawal'] ?? 0),
            _buildWalletRow('Total Earnings', wallet['totalEarnings'] ?? 0),
            _buildWalletRow('Total Withdrawn', wallet['totalWithdrawn'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _HostTile extends StatelessWidget {
  final Map<String, dynamic> host;
  const _HostTile({required this.host});

  @override
  Widget build(BuildContext context) {
    final earnings = host['currentMonthEarnings'] ?? 0;
    final commission = host['currentMonthCommission'] ?? 0;
    final target = host['currentMonthTargetCoins'] ?? 0;
    final name = host['name'] ?? 'Unknown';
    final avatar = host['avatar'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
          child: avatar.isEmpty ? Text(name[0]) : null,
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target: $target coins'),
            Text('Earnings: $earnings | Commission: $commission'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$earnings',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            Text(
              '+$commission',
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}