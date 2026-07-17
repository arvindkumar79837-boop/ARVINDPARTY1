import 'package:get/get.dart';
import '../services/auth_session_manager.dart';

class AuthGuardMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthSessionManager>();
    if (auth.authStatus.value != AuthStatus.authenticated) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}
