import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/feature_flag_service.dart';
import '../repositories/analytics_repository.dart';

class AnalyticsController extends GetxController {
  final AnalyticsRepository _repository = AnalyticsRepository();
  final ApiService _apiService = Get.find<ApiService>();
  final FeatureFlagService _featureFlagService = Get.find<FeatureFlagService>();

  var isLoadingRevenue = true.obs;
  var isLoadingEngagement = true.obs;
  var isLoadingDepartmental = true.obs;
  var isLoadingCharts = true.obs;

  var revenueSummary = Rxn<Map<String, dynamic>>();
  var rechargeAnalytics = RxList<Map<String, dynamic>>();
  var withdrawalAnalytics = RxList<Map<String, dynamic>>();
  var userAnalytics = Rxn<Map<String, dynamic>>();
  var liveAnalytics = Rxn<Map<String, dynamic>>();
  var giftAnalytics = Rxn<Map<String, dynamic>>();
  var agencyRankings = RxList<Map<String, dynamic>>();
  var familyRankings = RxList<Map<String, dynamic>>();
  var chartData = Rxn<Map<String, dynamic>>();
  var heatMapData = RxList<Map<String, dynamic>>();

  IO.Socket? _socket;

  @override
  void onInit() {
    super.onInit();
    _setupSocket();
    fetchAllData();
  }

  @override
  void onClose() {
    _disposeSocket();
    super.onClose();
  }

  void _setupSocket() {
    if (!_featureFlagService.advancedAnalyticsEnabled) return;

    final token = _apiService.getToken();
    if (token == null) return;

    try {
      _socket = IO.io(
        '${EnvConfig.socketUrl}/analytics',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) {
        print('Analytics Socket: Connected');
      });

      _socket!.on('initial_data', (dynamic data) {
        if (data == null) return;
        final Map<String, dynamic> map = data as Map<String, dynamic>;
        if (map['revenueSummary'] != null) {
          revenueSummary.value = map['revenueSummary'] as Map<String, dynamic>?;
        }
        if (map['userAnalytics'] != null) {
          userAnalytics.value = map['userAnalytics'] as Map<String, dynamic>?;
        }
        if (map['liveAnalytics'] != null) {
          liveAnalytics.value = map['liveAnalytics'] as Map<String, dynamic>?;
        }
        if (map['chartData'] != null) {
          chartData.value = map['chartData'] as Map<String, dynamic>?;
        }
      });

      _socket!.on('revenue_summary_updated', (dynamic data) {
        if (data != null) revenueSummary.value = data as Map<String, dynamic>?;
      });

      _socket!.on('live_analytics_updated', (dynamic data) {
        if (data != null) liveAnalytics.value = data as Map<String, dynamic>?;
      });

      _socket!.on('chart_data_updated', (dynamic data) {
        if (data != null) chartData.value = data as Map<String, dynamic>?;
      });

      _socket!.on('gift_analytics_updated', (dynamic data) {
        if (data != null) giftAnalytics.value = data as Map<String, dynamic>?;
      });

      _socket!.on('agency_analytics_updated', (dynamic data) {
        if (data != null) {
          final List<dynamic> list = data as List<dynamic>;
          agencyRankings.value = list.cast<Map<String, dynamic>>();
        }
      });

      _socket!.on('family_analytics_updated', (dynamic data) {
        if (data != null) {
          final List<dynamic> list = data as List<dynamic>;
          familyRankings.value = list.cast<Map<String, dynamic>>();
        }
      });

      _socket!.on('heatmap_data_updated', (dynamic data) {
        if (data != null) {
          final List<dynamic> list = data as List<dynamic>;
          heatMapData.value = list.cast<Map<String, dynamic>>();
        }
      });

      _socket!.onDisconnect((_) => print('Analytics Socket: Disconnected'));
      _socket!.onError((error) => print('Analytics Socket Error: $error'));
    } catch (e) {
      print('Error setting up analytics socket: $e');
    }
  }

  void _disposeSocket() {
    _socket?.dispose();
  }

  Future<void> fetchAllData() async {
    await Future.wait([
      fetchRevenueData(),
      fetchEngagementData(),
      fetchDepartmentalData(),
      fetchChartData(),
    ]);
  }

  Future<void> fetchRevenueData() async {
    try {
      isLoadingRevenue(true);
      final summary = await _repository.getRevenueSummary();
      revenueSummary.value = summary;
    } catch (e) {
      print('Error fetching revenue data: $e');
    } finally {
      isLoadingRevenue(false);
    }
  }

  Future<void> fetchRechargeAnalytics({int page = 1}) async {
    try {
      final result = await _repository.getRechargeAnalytics(page: page);
      final results = result['results'];
      if (results != null) {
        rechargeAnalytics.value = (results as List<dynamic>).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching recharge analytics: $e');
    }
  }

  Future<void> fetchWithdrawalAnalytics({int page = 1}) async {
    try {
      final result = await _repository.getWithdrawalAnalytics(page: page);
      final results = result['results'];
      if (results != null) {
        withdrawalAnalytics.value = (results as List<dynamic>).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching withdrawal analytics: $e');
    }
  }

  Future<void> fetchEngagementData() async {
    try {
      isLoadingEngagement(true);
      final results = await Future.wait([
        _repository.getUserAnalytics(),
        _repository.getLiveAnalytics(),
        _repository.getGiftAnalytics(),
      ]);
      userAnalytics.value = results[0];
      liveAnalytics.value = results[1];
      giftAnalytics.value = results[2];
    } catch (e) {
      print('Error fetching engagement data: $e');
    } finally {
      isLoadingEngagement(false);
    }
  }

  Future<void> fetchDepartmentalData() async {
    try {
      isLoadingDepartmental(true);
      final results = await Future.wait([
        _repository.getAgencyAnalytics(),
        _repository.getFamilyAnalytics(),
      ]);
      agencyRankings.value = (results[0]).cast<Map<String, dynamic>>();
      familyRankings.value = (results[1]).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching departmental data: $e');
    } finally {
      isLoadingDepartmental(false);
    }
  }

  Future<void> fetchChartData() async {
    try {
      isLoadingCharts(true);
      final results = await Future.wait([
        _repository.getLiveChartData(),
        _repository.getHeatMapData(),
      ]);
      final chartResult = results[0];
      chartData.value = chartResult as Map<String, dynamic>?;
          final heatData = results[1];
      heatMapData.value = (heatData as List<dynamic>).cast<Map<String, dynamic>>();
        } catch (e) {
      print('Error fetching chart data: $e');
    } finally {
      isLoadingCharts(false);
    }
  }

  Future<void> refreshAll() async {
    await fetchAllData();
    _socket?.emit('request_revenue_update');
    _socket?.emit('request_live_update');
    _socket?.emit('request_chart_update');
    _socket?.emit('request_gift_update');
    _socket?.emit('request_agency_update');
    _socket?.emit('request_family_update');
  }
}