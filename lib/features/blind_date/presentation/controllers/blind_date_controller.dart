import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../repositories/blind_date_repository.dart';

class BlindDateController extends GetxController {
  final BlindDateRepository blindDateRepository;

  BlindDateController(this.blindDateRepository);

  var isSearching = false.obs;
  var match = Rx<Map<String, dynamic>?>(null);
  var errorMessage = ''.obs;

  Future<void> startSearch() async {
    try {
      isSearching.value = true;
      errorMessage.value = '';
      final result = await blindDateRepository.searchMatch();
      match.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to start search');
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> stopSearch() async {
    try {
      await blindDateRepository.stopSearch();
    } catch (e) {
      Get.snackbar('Error', 'Failed to stop search');
    } finally {
      isSearching.value = false;
    }
  }

  void joinMatchRoom() {
    final matchData = match.value;
    if (matchData == null) {
      Get.snackbar('Error', 'No match found to join');
      return;
    }

    final roomId = matchData['roomId'] ?? matchData['data']?['roomId'];
    if (roomId == null || roomId.toString().isEmpty) {
      Get.snackbar('Error', 'Room ID not available');
      return;
    }

    Get.snackbar('Joining', 'Entering blind date room...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF8906),
        colorText: Colors.white);

    Get.toNamed(AppRoutes.liveRoom, arguments: {
      'roomId': roomId.toString(),
      'isBlindDate': true,
      'matchData': matchData,
    });
  }

  void reset() {
    match.value = null;
    errorMessage.value = '';
    isSearching.value = false;
  }

}
