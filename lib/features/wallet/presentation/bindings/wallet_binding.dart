// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/bindings/wallet_binding.dart
// ARVIND PARTY - UNIFIED WALLET BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../controllers/withdrawal_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    // Wallet Controller (for balance management)
    Get.lazyPut<WalletController>(
      () => WalletController(),
      fenix: true,
    );

    // Withdrawal Controller (for withdrawal requests)
    Get.lazyPut<WithdrawalController>(
      () => WithdrawalController(),
      fenix: true,
    );
  }
}