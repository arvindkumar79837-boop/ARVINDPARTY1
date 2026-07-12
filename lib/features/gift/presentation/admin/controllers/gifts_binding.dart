import 'package:arvind_party/features/gift/presentation/admin/controllers/gifts_controller.dart';
import 'package:get/get.dart';

class GiftsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftsController>(() => GiftsController());
  }
}