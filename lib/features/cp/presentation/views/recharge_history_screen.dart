// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/cp/presentation/views/recharge_history_screen.dart
// ARVIND PARTY - RECHARGE HISTORY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class RechargeHistoryScreen extends StatelessWidget {
  const RechargeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharge History'),
      ),
      body: const Center(
        child: Text('Recharge History Screen'),
      ),
    );
  }
}
