// ═══════════════════════════════════════════════════════════════════════════
// VIEW: AdminWalletManagementView — Admin wallet overview
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';

class AdminWalletManagementView extends StatelessWidget {
  const AdminWalletManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Management')),
      body: const Center(child: Text('Admin Wallet Management')),
    );
  }
}