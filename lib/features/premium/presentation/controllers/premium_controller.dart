import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/google_play_billing_service.dart';
import '../../../core/services/auth_session_manager.dart';

class SubscriptionTier {
  final String id;
  final String tierName;
  final double priceINR;
  final int durationDays;
  final Map<String, dynamic> perks;
  final String googlePlayProductId;
  final String description;
  final int sortOrder;

  SubscriptionTier({
    required this.id,
    required this.tierName,
    required this.priceINR,
    required this.durationDays,
    required this.perks,
    this.googlePlayProductId = '',
    this.description = '',
    this.sortOrder = 0,
  });

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) {
    return SubscriptionTier(
      id: json['_id'] ?? json['id'] ?? '',
      tierName: json['tierName'] ?? '',
      priceINR: (json['priceINR'] ?? 0).toDouble(),
      durationDays: json['durationDays'] ?? 30,
      perks: json['perks'] ?? {},
      googlePlayProductId: json['googlePlayProductId'] ?? '',
      description: json['description'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
    );
  }
}

class PremiumController extends GetxController {
  final _api = Get.find<ApiService>();

  final tiers = <SubscriptionTier>[].obs;
  final isLoading = true.obs;
  final isPurchasing = false.obs;

  // My subscription
  final myTierName = ''.obs;
  final myExpiresAt = Rxn<DateTime>();
  final myIsActive = false.obs;
  final myPerks = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTiers();
    fetchMySubscription();
  }

  Future<void> fetchTiers() async {
    try {
      isLoading.value = true;
      final resp = await _api.dio.get('/subscriptions/tiers');
      if (resp.data['success'] == true) {
        final list = (resp.data['data'] as List?) ?? [];
        tiers.value = list.map((e) => SubscriptionTier.fromJson(e)).toList();
        tiers.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }
    } catch (e) {
      debugPrint('fetchTiers error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMySubscription() async {
    try {
      final resp = await _api.dio.get('/subscriptions/my-subscription');
      if (resp.data['success'] == true) {
        final data = resp.data['data'];
        if (data != null) {
          myTierName.value = data['tierName'] ?? '';
          myExpiresAt.value = data['expiresAt'] != null ? DateTime.tryParse(data['expiresAt']) : null;
          myIsActive.value = data['isActive'] ?? false;
          myPerks.value = Map<String, dynamic>.from(data['perks'] ?? {});
        } else {
          myTierName.value = '';
          myExpiresAt.value = null;
          myIsActive.value = false;
          myPerks.clear();
        }
      }
    } catch (e) {
      debugPrint('fetchMySubscription error: $e');
    }
  }

  Future<void> purchaseTier(SubscriptionTier tier) async {
    if (tier.googlePlayProductId.isEmpty) {
      Get.snackbar('Error', 'Subscription product not configured',
          backgroundColor: Colors.red.shade900, colorText: Colors.white);
      return;
    }

    isPurchasing.value = true;
    try {
      final billing = Get.find<GooglePlayBillingService>();
      final products = await billing.loadProducts([tier.googlePlayProductId]);
      if (products.isEmpty) {
        Get.snackbar('Error', 'Product not found on Play Store',
            backgroundColor: Colors.red.shade900, colorText: Colors.white);
        return;
      }
      await billing.buyProduct(products.first);
      // After purchase completes, verify on backend
      // The billing service's purchaseStream handler will call verify-play-subscription
      await fetchMySubscription();
    } catch (e) {
      Get.snackbar('Error', 'Purchase failed: $e',
          backgroundColor: Colors.red.shade900, colorText: Colors.white);
    } finally {
      isPurchasing.value = false;
    }
  }

  Future<void> claimMonthlyCoins() async {
    try {
      final resp = await _api.dio.post('/subscriptions/claim-monthly-coins');
      if (resp.data['success'] == true) {
        Get.snackbar('Success', resp.data['message'] ?? 'Coins claimed!',
            backgroundColor: const Color(0xFF1A1A2E), colorText: Colors.white);
      } else {
        Get.snackbar('Info', resp.data['message'] ?? 'Cannot claim yet',
            backgroundColor: Colors.orange.shade900, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to claim coins',
          backgroundColor: Colors.red.shade900, colorText: Colors.white);
    }
  }

  String get tierIcon {
    if (myTierName.value == 'Royal') return '👑';
    if (myTierName.value == 'Gold') return '🥇';
    if (myTierName.value == 'Silver') return '🥈';
    return '⭐';
  }

  Color get tierColor {
    if (myTierName.value == 'Royal') return const Color(0xFF9C27B0);
    if (myTierName.value == 'Gold') return const Color(0xFFFFB300);
    if (myTierName.value == 'Silver') return const Color(0xFF90A4AE);
    return const Color(0xFF546E7A);
  }
}
