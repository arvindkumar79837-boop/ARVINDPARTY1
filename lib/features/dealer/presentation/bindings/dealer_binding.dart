import 'package:get/get.dart';

import '../../services/dealer_service.dart';
import '../controllers/dealer_controller.dart';

class DealerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DealerService>(DealerService(), permanent: true);
    Get.lazyPut<DealerController>(() => DealerController());
  }
}
