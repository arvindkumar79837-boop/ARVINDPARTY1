import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../services/api_service.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var loadingMessage = ''.obs;
  var isTermsAccepted = false.obs;

  void toggleTerms() {
    isTermsAccepted.value = !isTermsAccepted.value;
  }

  bool _checkTerms() {
    if (!isTermsAccepted.value) {
      Get.snackbar(
        'Terms & Conditions',
        'Please accept the Terms of Use and Privacy Policy first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }

  // ==========================================
  // 1. REAL GOOGLE LOGIN
  // ==========================================
  Future<void> loginWithGoogle() async {
    if (!_checkTerms()) return;

    try {
      isLoading(true);
      loadingMessage('Connecting to Google...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading(false); // User canceled
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      loadingMessage('Authenticating...');
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Send real data to Arvind Party Node.js Backend
      await _authenticateWithBackend(
        provider: 'google',
        uid: userCredential.user!.uid,
        email: userCredential.user!.email,
        name: userCredential.user!.displayName,
        avatar: userCredential.user!.photoURL,
      );
    } catch (e) {
      Get.snackbar('Login Failed', e.toString());
      isLoading(false);
    }
  }

  // ==========================================
  // 2. REAL PHONE LOGIN NAVIGATION
  // ==========================================
  void goToPhoneAuth() {
    if (!_checkTerms()) return;
    Get.toNamed('/phone-login'); // Will navigate to the real Phone OTP screen
  }

  // Other Authenticators (To be implemented next)
  Future<void> loginWithFacebook() async {
    if (!_checkTerms()) return;
    Get.snackbar('Coming Soon', 'Real Facebook login is being configured.');
  }

  Future<void> loginWithWhatsApp() async {
    if (!_checkTerms()) return;
    Get.snackbar('Coming Soon', 'Real WhatsApp login is being configured.');
  }

  Future<void> loginWithApple() async {}
  Future<void> loginWithTwitter() async {}
  Future<void> loginWithSnapchat() async {}

  // ==========================================
  // 3. CONNECT TO ARVIND PARTY NODE.JS BACKEND
  // ==========================================
  Future<void> _authenticateWithBackend({
    required String provider,
    required String uid,
    String? email,
    String? phone,
    String? name,
    String? avatar,
  }) async {
    loadingMessage('Logging into Arvind Party...');

    try {
      var response = await _apiService.post('auth/login', {
        'provider': provider,
        'uid': uid,
        'email': email,
        'phone': phone,
        'name': name,
        'avatar': avatar,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        _apiService.saveToken(response.data['token']);
        bool isNewUser = response.data['isNewUser'] ?? false;
        Get.offAllNamed(isNewUser ? '/complete-profile' : '/home');
      }
    } catch (e) {
      Get.snackbar(
          'Server Error', 'Failed to connect to Arvind Party servers.');
      isLoading(false);
    }
  }
}
