// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/services/payment_service.dart
// ARVIND PARTY - PAYMENT SERVICE (DEPRECATED — Razorpay removed)
//
// Coins are now purchased exclusively via Google Play Billing.
// See: lib/core/services/google_play_billing_service.dart
// Backend: POST /api/economy/verify-google-play
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

/// DEPRECATED: This service previously integrated Razorpay for coin purchases.
/// It is retained as an empty stub to avoid breaking imports in any files
/// that haven't been fully migrated yet. All payment logic now lives in
/// [GooglePlayBillingService].
class PaymentService extends GetxService {
  static PaymentService get to => Get.find<PaymentService>();

  var isProcessing = false.obs;
  var currentPaymentStatus = 'idle'.obs;

  bool get isReady => true;

  void resetStatus() {
    isProcessing.value = false;
    currentPaymentStatus.value = 'idle';
  }

  @override
  void onClose() {
    super.onClose();
  }
}
