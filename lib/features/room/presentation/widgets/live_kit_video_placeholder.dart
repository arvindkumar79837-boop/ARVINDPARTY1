// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/presentation/widgets/live_kit_video_placeholder.dart
// PLACEHOLDER: Real video rendering will be implemented after LiveKit connector is complete.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Keeps the same layout slot previously used by AgoraVideoViewer.
/// Replace with real LiveKit track rendering once the client layer is fully integrated.
class LiveKitVideoPlaceholder extends StatelessWidget {
  const LiveKitVideoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'Live Room Audio',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}
