// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/views/placeholder_wallet_screen.dart
// ARVIND PARTY - PLACEHOLDER WALLET SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class PlaceholderWalletScreen extends StatelessWidget {
  final String title;

  const PlaceholderWalletScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'This is the $title screen.',
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}
