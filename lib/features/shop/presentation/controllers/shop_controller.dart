// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/shop/presentation/controllers/shop_controller.dart
// ARVIND PARTY - SHOP CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../repositories/shop_repository.dart';

class ShopController extends GetxController {
  final isLoading = false.obs;
  final isPurchasing = false.obs;
  final shopItems = <Map<String, dynamic>>[].obs;
  final categories = <String>[].obs;
  final selectedCategory = RxString('All');

  final ShopRepository _repo = ShopRepository();

  @override
  void onInit() {
    super.onInit();
    fetchShopItems();
  }

  List<Map<String, dynamic>> get filteredItems {
    if (selectedCategory.value == 'All') return shopItems;
    return shopItems.where((item) => (item['type'] as String?) == selectedCategory.value).toList();
  }

  Future<void> fetchShopItems() async {
    try {
      isLoading.value = true;
      final items = await _repo.fetchItems();
      shopItems.assignAll(items);

      // Extract unique categories
      final cats = <String>{'All'};
      for (final item in items) {
        final type = item['type'] as String?;
        if (type != null) cats.add(type[0].toUpperCase() + type.substring(1));
      }
      categories.assignAll(cats.toList());
    } catch (e) {
      Get.snackbar('Error', 'Failed to load shop items');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> purchaseItem(String itemId, String itemName, int price) async {
    try {
      isPurchasing.value = true;
      final result = await _repo.purchaseItem(itemId);
      if (result['message'] != null) {
        Get.snackbar('Success', result['message'] as String);
        fetchShopItems();
      } else {
        Get.snackbar('Error', result['message'] as String? ?? 'Purchase failed');
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Purchase Failed', msg);
    } finally {
      isPurchasing.value = false;
    }
  }

  void setCategory(String cat) => selectedCategory.value = cat;
}
