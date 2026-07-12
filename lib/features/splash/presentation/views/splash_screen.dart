// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/splash/presentation/views/splash_screen.dart
// ARVIND PARTY - ULTRA UPDATED SPLASH SCREEN (BIGGER ICON EDITION)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0C20), // Gehra navy/black
              Color(0xFF15102A), // Dark purple tone
              Color(0xFF06040A), // Pure dark night club vibe
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Neon Glow Circle
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25, // Positioning adjusted for bigger icon
              child: Container(
                width: 320, // Glow thoda bada kiya taaki icon ko space mile
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF8906).withOpacity(0.12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8906).withOpacity(0.12),
                      blurRadius: 110,
                    ),
                  ],
                ),
              ),
            ),
            
            // Main Content (Logo, Name & Loader)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ⚡ ULTRA ICON CONTAINER (Bigger & Glowing)
                  Container(
                    width: 180,  // Size 140 se badhakar 180 kiya
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24), // Sharp edges ko smooth kiya
                      border: Border.all(
                        color: const Color(0xFFFF8906).withOpacity(0.4), // Patli neon outer line
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8906).withOpacity(0.25),
                          blurRadius: 35,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    // ClipRRect taaki logo image bhi corners par smooth kate
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/splash/logo.png', 
                        fit: BoxFit.cover, // Image ko box me perfect fit karne ke liye
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Gap adjusted for bigger icon
                  
                  // 'ARVIND PARTY' - Premium Neon Text Style
                  Text(
                    'ARVIND PARTY',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: <Color>[
                            Color(0xFFFF8906),
                            Color(0xFFFF3E6C),
                          ],
                        ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                      shadows: [
                        Shadow(
                          blurRadius: 15.0,
                          color: const Color(0xFFFF3E6C).withOpacity(0.5),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Customized Premium Circular Loader
                  const SizedBox(
                    width: 45,
                    height: 45,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8906)),
                      backgroundColor: Color(0xFF251F3D),
                    ),
                  ),
                ],
              ),
            ),
            
            // Version Text
            Positioned(
              bottom: 40,
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}