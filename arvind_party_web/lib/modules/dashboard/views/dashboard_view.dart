import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DashboardController());
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF8906)),
                );
              }
              return Row(
                children: [
                  _buildStatCard(
                    'Total App Users',
                    controller.totalUsers.value.toString(),
                    Icons.people_alt,
                    Colors.blueAccent,
                  ),
                  const SizedBox(width: 24),
                  _buildStatCard(
                    'Active Live Rooms',
                    controller.activeRooms.value.toString(),
                    Icons.meeting_room,
                    Colors.greenAccent,
                  ),
                  const SizedBox(width: 24),
                  _buildStatCard(
                    'Total Coins Generated',
                    '🪙 ${controller.totalRevenue.value}',
                    Icons.monetization_on,
                    Colors.yellow,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
