import 'package:get/get.dart';
import '../repositories/analytics_repository.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    final repo = AnalyticsRepository();
    Get.lazyPut<AnalyticsRepository>(() => repo);
    Get.lazyPut<AnalyticsController>(() => AnalyticsController(repo));
  }
}
