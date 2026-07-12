import 'package:get/get.dart';
import '../repositories/analytics_repository.dart';

class AnalyticsController extends GetxController {
  final AnalyticsRepository analyticsRepository;

  AnalyticsController(this.analyticsRepository);

  var isLoadingRevenue = false.obs;
  var isLoadingEngagement = false.obs;
  var isLoadingDepartmental = false.obs;
  var isLoadingCharts = false.obs;

  var revenueSummary = Rxn<Map<String, dynamic>>();
  var userAnalytics = Rxn<Map<String, dynamic>>();
  var liveAnalytics = Rxn<Map<String, dynamic>>();
  var giftAnalytics = Rxn<Map<String, dynamic>>();
  var agencyRankings = <Map<String, dynamic>>[].obs;
  var familyRankings = <Map<String, dynamic>>[].obs;
  var chartData = Rxn<Map<String, dynamic>>();
  var heatMapData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadRevenueData(),
      loadEngagementData(),
      loadDepartmentalData(),
      loadChartsData(),
    ]);
  }

  Future<void> loadRevenueData() async {
    try {
      isLoadingRevenue.value = true;
      final data = await analyticsRepository.getRevenueSummary();
      revenueSummary.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load revenue data');
    } finally {
      isLoadingRevenue.value = false;
    }
  }

  Future<void> loadEngagementData() async {
    try {
      isLoadingEngagement.value = true;
      final userData = await analyticsRepository.getUserAnalytics();
      final liveData = await analyticsRepository.getLiveAnalytics();
      final giftData = await analyticsRepository.getGiftAnalytics();
      userAnalytics.value = userData;
      liveAnalytics.value = liveData;
      giftAnalytics.value = giftData;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load engagement data');
    } finally {
      isLoadingEngagement.value = false;
    }
  }

  Future<void> loadDepartmentalData() async {
    try {
      isLoadingDepartmental.value = true;
      final agencies = await analyticsRepository.getAgencyRankings();
      final families = await analyticsRepository.getFamilyRankings();
      agencyRankings.value = agencies;
      familyRankings.value = families;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load departmental data');
    } finally {
      isLoadingDepartmental.value = false;
    }
  }

  Future<void> loadChartsData() async {
    try {
      isLoadingCharts.value = true;
      final hourly = await analyticsRepository.getHourlyRevenue();
      final heatMap = await analyticsRepository.getActivityHeatMap();
      chartData.value = hourly;
      heatMapData.value = heatMap;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load charts data');
    } finally {
      isLoadingCharts.value = false;
    }
  }
}