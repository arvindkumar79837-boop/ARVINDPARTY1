import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../../lib/modules/home/views/main.dart'; // AdminDashboard yahan hai
import '../../core/constants/api_constants.dart';

class StaffLoginView extends StatefulWidget {
  const StaffLoginView({super.key});

  @override
  State<StaffLoginView> createState() => _StaffLoginViewState();
}

class _StaffLoginViewState extends State<StaffLoginView> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    final loginId = _loginIdController.text.trim();
    final password = _passwordController.text.trim();

    if (loginId.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter both Login ID and Password',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/staff/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'loginId': loginId,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save Token & Details to Local Storage
        final box = GetStorage();
        await box.write('staff_token', data['token']);
        await box.write('staff_role', data['staff']['role']);
        await box.write('staff_uid', data['staff']['uid']);

        Get.snackbar('Welcome', 'Login successful!',
            backgroundColor: Colors.green, colorText: Colors.white);

        // Navigate to Dashboard
        Get.offAll(() => const AdminDashboard());
      } else {
        throw Exception(data['message'] ?? 'Invalid login credentials');
      }
    } catch (e) {
      Get.snackbar('Login Failed', e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFF8906).withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 64, color: Color(0xFFFF8906)),
              const SizedBox(height: 16),
              const Text(
                'ARVIND PARTY',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              const Text(
                'STAFF PORTAL',
                style: TextStyle(
                    color: Color(0xFFFF8906), fontSize: 14, letterSpacing: 4),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _loginIdController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Login ID',
                  labelStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.person, color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFF8906))),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white54),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFF8906))),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8906),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('SECURE LOGIN',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
