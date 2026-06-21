// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/blind_date/presentation/controllers/blind_date_controller.dart
// ARVIND PARTY - BLIND DATE CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../repositories/blind_date_repository.dart';

class BlindDateController extends GetxController {
  final isSearching = false.obs;
  final match = Rxn<Map<String, dynamic>>();
  final errorMessage = RxString('');

  final BlindDateRepository _repo = BlindDateRepository();

  /// Start searching for a blind date match
  Future<void> startSearch() async {
    if (isSearching.value) return;

    try {
      isSearching.value = true;
      errorMessage.value = '';
      match.value = null;

      final result = await _repo.searchMatch();
      final foundMatch = result['match'] as Map<String, dynamic>?;

      if (foundMatch != null && foundMatch.isNotEmpty) {
        match.value = foundMatch;
      } else {
        errorMessage.value = 'No match found. Please try again.';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isSearching.value = false;
    }
  }

  /// Stop searching
  Future<void> stopSearch() async {
    try {
      await _repo.stopSearch();
    } catch (_) {
      // Silently ignore stop errors
    } finally {
      isSearching.value = false;
      match.value = null;
      errorMessage.value = '';
    }
  }

  /// Reset to try again
  void reset() {
    match.value = null;
    errorMessage.value = '';
    isSearching.value = false;
  }
}