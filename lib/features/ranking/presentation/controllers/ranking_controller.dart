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
  final selectedPeriod = 'daily'.obs;
  final selectedCountry = 'global'.obs;
  final errorMessage = RxnString();
  final myRanks = <String, int>{}.obs;

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

  Future<void> fetchRankingsWithFilters({String? type, String? period, String? country}) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final rankingType = _normalizeType(type ?? selectedType.value);
      selectedType.value = rankingType;
      if (period != null) selectedPeriod.value = period;
      if (country != null) selectedCountry.value = country;

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
      case 'families':
        return 'Family Ranking';
      case 'agencies':
        return 'Agency Ranking';
      case 'rooms':
        return 'Room Ranking';
      case 'pk-battles':
        return 'PK Battle Ranking';
      case 'rich-list':
        return 'Rich List';
      case 'popular-list':
        return 'Popular List';
      case 'wealth':
      default:
        return 'Wealth Ranking';
    }
  }

  String get scoreField {
    switch (selectedType.value) {
      case 'charm':
      case 'popular-list':
        return 'coins';
      case 'gift':
        return 'score';
      case 'wealth':
      case 'rich-list':
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
      case 'families':
        return 'families';
      case 'agencies':
        return 'agencies';
      case 'rooms':
        return 'rooms';
      case 'pk-battles':
        return 'pk-battles';
      case 'rich-list':
        return 'rich-list';
      case 'popular-list':
        return 'popular-list';
      case 'wealth':
      default:
        return 'wealth';
    }
  }

  Future<void> fetchMyRanks() async {
    try {
      final ranks = await _rankingRepository.fetchRankings('wealth');
      if (ranks.isNotEmpty) {
        myRanks.assignAll({'wealth': 0});
      }
    } catch (e) {
      myRanks.clear();
    }
  }
}
