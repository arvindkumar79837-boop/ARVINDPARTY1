// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/ranking/presentation/controllers/ranking_controller.dart
// ARVIND PARTY - RANKING CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../repositories/ranking_repository.dart';

class RankingController extends GetxController {
  RankingController({RankingRepository? rankingRepository})
      : _rankingRepository = rankingRepository ?? RankingRepository();

  final isLoading = false.obs;
  final rankings = <Map<String, dynamic>>[].obs;
  final selectedType = 'wealth'.obs;
  final errorMessage = RxnString();

  final RankingRepository _rankingRepository;

  @override
  void onInit() {
    super.onInit();
    selectedType.value = _resolveInitialType();
    fetchRankings();
  }

  Future<void> fetchRankings([String? type]) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final rankingType = _normalizeType(type ?? selectedType.value);
      selectedType.value = rankingType;

      final fetchedRankings = await _rankingRepository.fetchRankings(rankingType);
      rankings.assignAll(fetchedRankings);
    } catch (e) {
      rankings.clear();
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load ${selectedType.value} rankings');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshRankings() => fetchRankings(selectedType.value);

  String get screenTitle {
    switch (selectedType.value) {
      case 'charm':
        return 'Charm Ranking';
      case 'gift':
        return 'Gift Ranking';
      case 'wealth':
      default:
        return 'Wealth Ranking';
    }
  }

  String get scoreField {
    switch (selectedType.value) {
      case 'charm':
        return 'coins';
      case 'gift':
        return 'score';
      case 'wealth':
      default:
        return 'diamonds';
    }
  }

  String _resolveInitialType() {
    final argument = Get.arguments;

    if (argument is String && argument.isNotEmpty) {
      return _normalizeType(argument);
    }

    if (argument is Map) {
      final type = argument['type']?.toString();
      if (type != null && type.isNotEmpty) {
        return _normalizeType(type);
      }
    }

    switch (Get.currentRoute) {
      case AppRoutes.charmRanking:
        return 'charm';
      case AppRoutes.giftRanking:
        return 'gift';
      case AppRoutes.wealthRanking:
      default:
        return 'wealth';
    }
  }

  String _normalizeType(String rawType) {
    switch (rawType.toLowerCase()) {
      case 'charm':
        return 'charm';
      case 'gift':
        return 'gift';
      case 'wealth':
      default:
        return 'wealth';
    }
  }
}
