import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../core/services/api_service.dart';

class GooglePlayBillingService extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final isAvailable = false.obs;
  final isProcessing = false.obs;
  List<ProductDetails> _products = [];

  @override
  void onInit() {
    super.onInit();
    _initStore();
  }

  Future<void> _initStore() async {
    try {
      isAvailable.value = await _iap.isAvailable();
      if (!isAvailable.value) return;
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) => debugPrint('IAP stream error: $error'),
      );
    } catch (e) {
      debugPrint('IAP init error: $e');
    }
  }

  Future<List<ProductDetails>> loadProducts(List<String> productIds) async {
    if (!isAvailable.value || productIds.isEmpty) return [];
    try {
      final response = await _iap.queryProductDetails(productIds.toSet());
      _products = response.productDetails;
      return _products;
    } catch (e) {
      debugPrint('IAP load products error: $e');
      return [];
    }
  }

  Future<void> buyProduct(ProductDetails product) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
    } catch (e) {
      isProcessing.value = false;
      Get.snackbar('Error', 'Purchase failed: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
      await _verifyOnServer(purchase);
    } else if (purchase.status == PurchaseStatus.error) {
      isProcessing.value = false;
      Get.snackbar('Error', 'Purchase error: ${purchase.error?.message}', snackPosition: SnackPosition.BOTTOM);
    }

    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  Future<void> _verifyOnServer(PurchaseDetails purchase) async {
    try {
      final api = Get.find<ApiService>();
      final productId = purchase.productID;
      final verificationData = purchase.verificationData;

      final response = await api.post('/economy/verify-google-play', body: {
        'productId': productId,
        'purchaseToken': verificationData.serverVerificationData,
        'packageName': 'com.arvindparty.app',
      });

      if (response['success'] == true) {
        isProcessing.value = false;
        final data = response['data'];
        Get.snackbar(
          'Recharge Successful',
          '${data['coinsCredited']} coins + ${data['diamondsCredited']} diamonds credited!',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.find<ApiService>();
      } else {
        isProcessing.value = false;
        Get.snackbar('Error', response['message'] ?? 'Verification failed', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      isProcessing.value = false;
      Get.snackbar('Error', 'Server verification failed: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> restorePurchases() async {
    if (!isAvailable.value) return;
    try {
      await _iap.restorePurchases();
      Get.snackbar('Restored', 'Purchases restored', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Restore failed: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  List<ProductDetails> get products => _products;

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
