// ═══════════════════════════════════════════════════════════════════════════
// WEB AUTH CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();
  final _storage = GetStorage();
  
  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var username = ''.obs;
  var email = ''.obs;
  var role = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  void _checkSession() {
    final token = _storage.read('admin_token');
    if (token != null) {
      isLoggedIn.value = true;
      username.value = _storage.read('admin_username') ?? 'Admin';
      email.value = _storage.read('admin_email') ?? '';
      role.value = _storage.read('admin_role') ?? 'admin';
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Demo login - in production, call real API
      if (username.isNotEmpty && password.isNotEmpty) {
        _storage.write('admin_token', 'demo_token_${DateTime.now().millisecondsSinceEpoch}');
        _storage.write('admin_username', username);
        _storage.write('admin_email', '$username@arvindparty.com');
        _storage.write('admin_role', 'admin');
        
        isLoggedIn.value = true;
        this.username.value = username;
        email.value = '$username@arvindparty.com';
        role.value = 'admin';
        
        return true;
      }
      
      errorMessage.value = 'Invalid credentials';
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _storage.remove('admin_token');
    _storage.remove('admin_username');
    _storage.remove('admin_email');
    _storage.remove('admin_role');
    
    isLoggedIn.value = false;
    username.value = '';
    email.value = '';
    role.value = '';
    
    Get.offAllNamed('/login');
  }
}