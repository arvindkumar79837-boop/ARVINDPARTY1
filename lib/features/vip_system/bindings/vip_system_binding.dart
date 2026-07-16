import 'package:get/get.dart';
import '../controllers/vip_system_controller.dart';

class VipSystemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VipSystemController>(() => VipSystemController());
  }
}
