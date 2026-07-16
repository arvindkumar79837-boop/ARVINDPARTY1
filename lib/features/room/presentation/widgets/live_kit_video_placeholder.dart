import 'dart:math';
import 'package:flutter/material.dart';

class LiveKitVideoPlaceholder extends StatefulWidget {
  const LiveKitVideoPlaceholder({super.key});

  @override
  State<LiveKitVideoPlaceholder> createState() => _LiveKitVideoPlaceholderState();
}

class _LiveKitVideoPlaceholderState extends State<LiveKitVideoPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1117),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final height = (16 + sin((_controller.value * pi * 2) + i * 0.8) * 20 + _random.nextDouble() * 8).clamp(8.0, 44.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 4,
                      height: height,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          const Color(0xFFFF8906),
                          Colors.purpleAccent,
                          i / 6,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 20),
            const Icon(Icons.wifi, color: Colors.white30, size: 24),
            const SizedBox(height: 8),
            const Text(
              'Live Room Audio',
              style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              'Voice streaming active',
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
