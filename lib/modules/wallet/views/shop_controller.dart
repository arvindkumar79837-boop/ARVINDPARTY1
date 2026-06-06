import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'shop_item_model.dart';
import '../../auth/views/api_service.dart';

class ShopController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final isLoading = false.obs;
  final selectedCategory = 'frame'.obs;
  final items = <ShopItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadShopData();
  }

  void _loadShopData() async {
    isLoading.value = true;

    try {
      var response = await _apiService.get('shop/items');

      if (response.statusCode == 200) {
        var fetchedItems = (response.data['items'] as List)
            .map((i) => ShopItemModel(
                id: i['_id'] ?? i['id'],
                name: i['name'],
                type: i['type'],
                priceDiamonds: i['priceDiamonds'],
                durationDays: i['durationDays'] ?? 7))
            .toList();

        items.assignAll(fetchedItems);
      }
    } catch (e) {
      Get.snackbar('Store Error', 'Failed to load shop items',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  List<ShopItemModel> get filteredItems =>
      items.where((item) => item.type == selectedCategory.value).toList();

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  void purchaseItem(ShopItemModel item) {
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF15141F),
      title:
          const Text('Purchase Confirm', style: TextStyle(color: Colors.white)),
      content: Text('Buy ${item.name} for ${item.priceDiamonds} diamonds?',
          style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
            onPressed: Get.back,
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white38))),
        TextButton(
          onPressed: () async {
            Get.back();
            isLoading.value = true;
            try {
              var response =
                  await _apiService.post('shop/purchase', {'itemId': item.id});
              if (response.statusCode == 200) {
                Get.snackbar('Success', '${item.name} purchased successfully!',
                    backgroundColor: Colors.green, colorText: Colors.white);
              } else {
                Get.snackbar('Failed',
                    response.data['message'] ?? 'Insufficient diamonds.',
                    backgroundColor: Colors.redAccent, colorText: Colors.white);
              }
            } catch (e) {
              Get.snackbar('Error', 'Failed to process transaction.',
                  backgroundColor: Colors.redAccent, colorText: Colors.white);
            } finally {
              isLoading.value = false;
            }
          },
          child: const Text('Buy Now',
              style: TextStyle(
                  color: Color(0xFFFF8906), fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }
}
