// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/cp/presentation/views/settlement_history_screen.dart
// ARVIND PARTY - SETTLEMENT HISTORY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class SettlementHistoryScreen extends StatelessWidget {
  const SettlementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settlement History'),
      ),
      body: const Center(
        child: Text('Settlement History Screen'),
      ),
    );
  }
}
