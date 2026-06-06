import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_center_models.dart';
import '../../auth/views/api_service.dart';

class UserCenterController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final isLoading = false.obs;

  final levelInfo = Rxn<UserLevelInfo>();
  final badges = <AppBadge>[].obs;
  final frames = <AvatarFrame>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserCenterData();
  }

  Future<void> _loadUserCenterData() async {
    isLoading.value = true;

    try {
      var response = await _apiService.get('users/center');
      if (response.statusCode == 200 && response.data != null) {
        var data = response.data;

        levelInfo.value = UserLevelInfo(
          currentLevel: data['levelInfo']?['currentLevel'] ?? 1,
          currentExp: data['levelInfo']?['currentExp'] ?? 0,
          nextLevelExp: data['levelInfo']?['nextLevelExp'] ?? 100,
        );

        if (data['badges'] != null) {
          badges.assignAll((data['badges'] as List)
              .map((b) => AppBadge(
                    id: b['id'],
                    name: b['name'],
                    description: b['description'],
                    iconPath: b['iconPath'],
                    isUnlocked: b['isUnlocked'] ?? false,
                  ))
              .toList());
        }

        if (data['frames'] != null) {
          frames.assignAll((data['frames'] as List)
              .map((f) => AvatarFrame(
                    id: f['id'],
                    name: f['name'],
                    imagePath: f['imagePath'],
                    isUnlocked: f['isUnlocked'] ?? false,
                    isEquipped: f['isEquipped'] ?? false,
                  ))
              .toList());
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user center data',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }

    isLoading.value = false;
  }

  void equipFrame(String frameId) {
    final frame = frames.firstWhereOrNull((f) => f.id == frameId);
    if (frame == null) return;

    _apiService
        .post('users/equip-frame', {'frameId': frameId}).then((response) {
      if (response.statusCode == 200) {
        final updatedList =
            frames.map((f) => f.copyWith(isEquipped: f.id == frameId)).toList();
        frames.assignAll(updatedList);
        Get.snackbar('Equipped', '${frame.name} frame equipped successfully!',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    }).catchError((error) {
      Get.snackbar('Error', 'Failed to equip frame',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    });
  }
}
