// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/splash/presentation/bindings/splash_binding.dart
// ARVIND PARTY - SPLASH BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // put() ensures the controller is instantiated immediately when the
    // splash route is entered, even if the view never explicitly calls
    // Get.find<SplashController>(). This is critical because SplashScreen
    // extends GetView<SplashController> but does not reference controller
    // in its build() method — lazyPut would never create the instance.
    Get.put<SplashController>(SplashController());
  }
}