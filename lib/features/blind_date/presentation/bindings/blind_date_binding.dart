import 'package:get/get.dart';
import '../controllers/blind_date_controller.dart';

class BlindDateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlindDateController>(() => BlindDateController());
  }
}
