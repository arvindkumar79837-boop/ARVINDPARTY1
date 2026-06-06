import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class GiftsController extends GetxController {
  final isLoading = true.obs;
  final gifts = <dynamic>[].obs;
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadGifts();
  }

  Future<void> loadGifts() async {
    isLoading.value = true;
    try {
      gifts.value = await AdminApi.to.getGifts();
    } catch (_) {
      gifts.value = [];
    }
    isLoading.value = false;
  }

  Future<void> addGift() async {
    if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
    final ok = await AdminApi.to.addGift({
      'giftId': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': nameCtrl.text,
      'price': int.tryParse(priceCtrl.text) ?? 10,
      'image': imageCtrl.text,
      'category': categoryCtrl.text.isEmpty ? 'Basic' : categoryCtrl.text,
      'animationType': 'default',
      'isActive': true,
    });
    if (ok) {
      nameCtrl.clear();
      priceCtrl.clear();
      imageCtrl.clear();
      categoryCtrl.clear();
      loadGifts();
      Get.back();
      Get.snackbar('✅ Gift Added', 'New gift has been added',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteGift(String id) async {
    final ok = await AdminApi.to.deleteGift(id);
    if (ok) {
      Get.snackbar('🗑️ Deleted', 'Gift deactivated',
          snackPosition: SnackPosition.BOTTOM);
      loadGifts();
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    imageCtrl.dispose();
    categoryCtrl.dispose();
    super.onClose();
  }
}
