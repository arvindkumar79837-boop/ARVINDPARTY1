// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/cp/presentation/views/coin_seller_profile_screen.dart
// ARVIND PARTY - COIN SELLER PROFILE SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class CoinSellerProfileScreen extends StatelessWidget {
  const CoinSellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Seller Profile'),
      ),
      body: const Center(
        child: Text('Coin Seller Profile Screen'),
      ),
    );
  }
}
