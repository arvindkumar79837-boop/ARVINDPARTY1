import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_service.dart';

class PhoneAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var verificationId = ''.obs;
  var currentPhone = ''.obs;

  // ==========================================
  // 1. SEND OTP VIA FIREBASE
  // ==========================================
  Future<void> sendOtp(String phoneNumber) async {
    isLoading(true);
    currentPhone.value = phoneNumber;

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (mostly on Android)
          UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          await _authenticateWithBackend(
            uid: userCredential.user!.uid,
            phone: userCredential.user!.phoneNumber ?? phoneNumber,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading(false);
          Get.snackbar(
              'Verification Failed', e.message ?? 'Unknown error occurred.');
        },
        codeSent: (String verId, int? resendToken) {
          isLoading(false);
          verificationId.value = verId;
          Get.toNamed('/otp-screen'); // Route to real OTP screen
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      isLoading(false);
      Get.snackbar('Error', e.toString());
    }
  }

  // ==========================================
  // 2. VERIFY OTP CODE
  // ==========================================
  Future<void> verifyOtp(String smsCode) async {
    isLoading(true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: smsCode,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      await _authenticateWithBackend(
        uid: userCredential.user!.uid,
        phone: userCredential.user!.phoneNumber ?? currentPhone.value,
      );
    } catch (e) {
      isLoading(false);
      Get.snackbar('Invalid OTP', 'The code you entered is incorrect.');
    }
  }

  // ==========================================
  // 3. CONNECT TO ARVIND PARTY NODE.JS BACKEND
  // ==========================================
  Future<void> _authenticateWithBackend(
      {required String uid, required String phone}) async {
    try {
      var response = await _apiService.post('auth/login', {
        'provider': 'phone',
        'uid': uid,
        'phone': phone,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        _apiService.saveToken(response.data['token']);
        bool isNewUser = response.data['isNewUser'] ?? false;
        Get.offAllNamed(isNewUser ? '/complete-profile' : '/home');
      }
    } catch (e) {
      Get.snackbar(
          'Server Error', 'Failed to connect to Arvind Party servers.');
    } finally {
      isLoading(false);
    }
  }
}
