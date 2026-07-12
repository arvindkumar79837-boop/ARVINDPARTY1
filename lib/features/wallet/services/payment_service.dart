// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/services/payment_service.dart
// ARVIND PARTY - RAZORPAY PAYMENT SERVICE
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/services/api_service.dart';

class PaymentService extends GetxService {
  static PaymentService get to => Get.find<PaymentService>();

  late Razorpay _razorpay;
  late ApiService _api;

  // Observables
  var isProcessing = false.obs;
  var currentPaymentStatus = 'idle'.obs; // idle, pending, success, failed

  // Arvind Party theme colors
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color darkBackground = Color(0xFF1A1A2E);

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
    _razorpay = Razorpay();
    _setupRazorpayHandlers();
  }

  void _setupRazorpayHandlers() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // ═══════ PUBLIC API ═══════════════════════════════════════════════════

  Future<void> initiatePayment({
    required int amount,
    required String packageName,
    required int coins,
    String? userId,
    String? userEmail,
    String? userPhone,
    String? userName,
  }) async {
    if (isProcessing.value) {
      throw Exception('Payment already in progress');
    }

    try {
      isProcessing.value = true;
      currentPaymentStatus.value = 'pending';

      // Step 1: Create order on backend
      final orderResponse = await _api.post(
        '/wallet/razorpay/order',
        body: {
          'amount': amount,
          'currency': 'INR',
          'receipt': 'order_${DateTime.now().millisecondsSinceEpoch}',
          'notes': {
            'packageName': packageName,
            'coins': coins.toString(),
            'userId': userId,
          },
        },
      );

      final orderId = orderResponse['orderId'];
      if (orderId == null) {
        throw Exception('Order creation failed');
      }

      // Step 2: Open Razorpay checkout
      final options = _buildCheckoutOptions(
        orderId: orderId,
        amount: amount,
        packageName: packageName,
        coins: coins,
        userName: userName ?? 'User',
        userEmail: userEmail ?? 'user@example.com',
        userPhone: userPhone ?? '9999999999',
      );

      _razorpay.open(options);
    } catch (e) {
      isProcessing.value = false;
      currentPaymentStatus.value = 'failed';
      debugPrint('[Payment] Initiate error: $e');
      rethrow;
    }
  }

  Future<bool> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    required int coins,
  }) async {
    try {
      final response = await _api.post(
        '/wallet/razorpay/verify',
        body: {
          'razorpayPaymentId': razorpayPaymentId,
          'razorpayOrderId': razorpayOrderId,
          'razorpaySignature': razorpaySignature,
          'coins': coins,
        },
      );

      return response['success'] == true;
    } catch (e) {
      debugPrint('[Payment] Verification error: $e');
      return false;
    }
  }

  Future<void> requestRefund({
    required String paymentId,
    required int amount,
    required String reason,
  }) async {
    try {
      await _api.post(
        '/wallet/razorpay/refund',
        body: {
          'paymentId': paymentId,
          'amount': amount,
          'reason': reason,
        },
      );
    } catch (e) {
      debugPrint('[Payment] Refund error: $e');
      rethrow;
    }
  }

  // ═══════ RAZORPAY HANDLERS ═════════════════════════════════════════════

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    isProcessing.value = false;
    currentPaymentStatus.value = 'success';
    debugPrint('[Payment] Success: ${response.paymentId}');

    Get.offAllNamed('/payment-success');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isProcessing.value = false;
    currentPaymentStatus.value = 'failed';
    debugPrint('[Payment] Error: ${response.message}');

    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Unknown error',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.9),
      colorText: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('[Payment] External wallet: ${response.walletName}');
    Get.snackbar(
      'Redirecting',
      'Opening ${response.walletName}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: primaryOrange.withValues(alpha: 0.9),
      colorText: Colors.white,
    );
  }

  // ═══════ OPTIONS BUILDER ══════════════════════════════════════════════

  Map<String, dynamic> _buildCheckoutOptions({
    required String orderId,
    required int amount,
    required String packageName,
    required int coins,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) {
    return {
      'key': 'YOUR_RAZORPAY_KEY', // ⚠️ CONFIGURE: Replace with actual Razorpay key from dashboard
      'amount': amount,
      'currency': 'INR',
      'name': 'Arvind Party',
      'description': '$packageName ($coins Coins)',
      'order_id': orderId,
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
        'name': userName,
      },
      'theme': {
        'color': '#FF6B35', // Arvind Party orange
      },
      'external': {
        'wallets': ['paytm', 'googlepay', 'phonepe'],
      },
    };
  }

  // ═══════ UTILITY METHODS ══════════════════════════════════════════════

  void resetStatus() {
    isProcessing.value = false;
    currentPaymentStatus.value = 'idle';
  }

  bool get isReady => true;

  Future<bool> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _api.get('/wallet/razorpay/status/$paymentId');
      return response['status'] == 'captured';
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> fetchTransactionHistory() async {
    try {
      final response = await _api.get('/wallet/transactions');
      return response['transactions'] ?? [];
    } catch (e) {
      debugPrint('[Payment] Fetch history error: $e');
      return [];
    }
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}