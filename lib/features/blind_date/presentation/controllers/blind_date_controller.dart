import 'package:get/get.dart';
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
    // TODO: Implement join match room functionality
    Get.snackbar('Info', 'Joining match room...');
  }

  void reset() {
    match.value = null;
    errorMessage.value = '';
    isSearching.value = false;
  }
}
