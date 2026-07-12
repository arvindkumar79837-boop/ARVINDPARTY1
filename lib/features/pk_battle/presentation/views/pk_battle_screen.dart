// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/pk_battle/presentation/views/pk_battle_screen.dart
// ARVIND PARTY - PK BATTLE SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pk_battle_controller.dart';

class PkBattleScreen extends GetView<PkBattleController> {
  const PkBattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PK Battle')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.redAccent)),
          );
        }

        // ─── Live Battle UI ──────────────────────────────────────────
        final liveBattle = controller.liveBattle.value;
        if (liveBattle != null) {
          return _buildLiveBattleUI(liveBattle, context);
        }

        // ─── Battle Request UI ───────────────────────────────────────
        final battleRequest = controller.battleRequest.value;
        if (battleRequest != null) {
          return _buildBattleRequestUI(battleRequest, context);
        }

        // ─── Initial State / Request New Battle ──────────────────────
        return _buildRequestNewBattleUI(context);
      }),
    );
  }

  Widget _buildRequestNewBattleUI(BuildContext context) {
    final opponentIdController = TextEditingController(text: 'opponent_user_id_example'); // Replace with actual user selection
    final roomIdController = TextEditingController(text: 'room_id_example'); // Replace with actual room selection

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flash_on, size: 80, color: Color(0xFFFF8906)),
          const SizedBox(height: 24),
          const Text(
            'Start a PK Battle!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: opponentIdController,
            decoration: const InputDecoration(labelText: 'Opponent User ID', labelStyle: TextStyle(color: Colors.grey)),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: roomIdController,
            decoration: const InputDecoration(labelText: 'Room ID', labelStyle: TextStyle(color: Colors.grey)),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              if (opponentIdController.text.isEmpty || roomIdController.text.isEmpty) {
                Get.snackbar('Error', 'Opponent ID and Room ID are required');
                return;
              }
              controller.requestPkBattle(
                opponentId: opponentIdController.text,
                roomId: roomIdController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8906),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Request PK Battle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleRequestUI(Map<String, dynamic> request, BuildContext context) {
    final hostName = request['hostName'] as String? ?? 'A Host';
    final hostAvatar = request['hostAvatar'] as String?;
    final battleId = request['battleId'] as String? ?? '';
    final roomId = request['roomId'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'PK Battle Request!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF8906)),
          ),
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF1A1A2E),
            backgroundImage: hostAvatar != null ? NetworkImage(hostAvatar) : null,
            child: hostAvatar == null ? Text(hostName[0], style: const TextStyle(fontSize: 40, color: Colors.white)) : null,
          ),
          const SizedBox(height: 16),
          Text(
            '$hostName wants to battle in Room ID: $roomId',
            style: const TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => controller.acceptPkBattle(battleId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('Accept', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () => controller.resetBattleState(), // Decline
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('Decline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBattleUI(Map<String, dynamic> battle, BuildContext context) {
    final hostId = battle['hostId'] as String? ?? '';
    final opponentId = battle['opponentId'] as String? ?? '';
    final battleId = battle['battleId'] as String? ?? '';
    final endTime = battle['endTime'] != null ? DateTime.parse(battle['endTime'] as String) : DateTime.now().add(const Duration(minutes: 5));

    // Scores are now being listened to by Obx
    final hostScore = controller.liveBattle.value?['hostScore'] ?? 0;
    final opponentScore = controller.liveBattle.value?['opponentScore'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text(
            'PK Battle LIVE!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF8906)),
          ),
          // ─── Score Display ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Host Score
              Column(
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: Colors.blueAccent, child: Text('Host', style: TextStyle(color: Colors.white))),
                  const SizedBox(height: 8),
                  Text(hostId, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text('$hostScore', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              // Opponent Score
              Column(
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: Colors.purpleAccent, child: Text('Opponent', style: TextStyle(color: Colors.white))),
                  const SizedBox(height: 8),
                  Text(opponentId, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text('$opponentScore', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          // ─── Timer ───────────────────────────────────────────────────
          Obx(() => Text(
            'Time Remaining: ${_formatDuration(endTime.difference(DateTime.now()))}',
            style: const TextStyle(fontSize: 20, color: Colors.white),
          )),
          // ─── Gift Simulation Buttons ────────────────────────────────
          Column(
            children: [
              const Text('Simulate Gift (Viewers)', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => controller.updateScore(battleId, 10, hostId),
                    child: const Text('Gift to Host (+10)'),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.updateScore(battleId, 10, opponentId),
                    child: const Text('Gift to Opponent (+10)'),
                  ),
                ],
              ),
            ],
          ),
          // ─── End Battle Button ──────────────────────────────────────
          ElevatedButton(
            onPressed: () => controller.endPkBattle(battleId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('End Battle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
