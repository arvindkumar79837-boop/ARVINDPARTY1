import 'package:get/get.dart';

import 'gifts_controller.dart';

class GiftsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftsController>(() => GiftsController());
  }
}