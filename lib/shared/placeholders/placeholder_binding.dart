import 'package:get/get.dart';

class PlaceholderController extends GetxController {
  // Minimal controller for placeholder
}

class PlaceholderBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlaceholderController>(() => PlaceholderController());
  }
}