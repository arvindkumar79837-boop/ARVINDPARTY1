import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_features_controller.dart';

class RoomFeaturesScreen extends StatefulWidget {
  final String roomId;
  final String userId;
  final String userName;
  final String userAvatar;

  const RoomFeaturesScreen({
    super.key,
    required this.roomId,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
  });

  @override
  State<RoomFeaturesScreen> createState() => _RoomFeaturesScreenState();
}

class _RoomFeaturesScreenState extends State<RoomFeaturesScreen> {
  final RoomFeaturesController controller = Get.find<RoomFeaturesController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Room Features'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Level', icon: Icon(Icons.star)),
              Tab(text: 'Social', icon: Icon(Icons.group)),
              Tab(text: 'Notices', icon: Icon(Icons.announcement)),
              Tab(text: 'Leaderboard', icon: Icon(Icons.leaderboard)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLevelTab(),
            _buildSocialTab(),
            _buildNoticesTab(),
            _buildLeaderboardTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level ${controller.roomLevel.value}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total XP: ${controller.totalXp.value}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.adminSlotLimit.value} Admin Slots',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final progress = controller.xpProgress.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'XP Progress',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${progress.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Online Users',
                      controller.onlineCount.value.toString(),
                      Icons.people,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'Max Seats',
                      controller.seatCapacity.value.toString(),
                      Icons.event_seat,
                      Colors.blue,
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 20),
          const Text(
            'Unlocked Rewards',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.unlockedBadges.isEmpty &&
                controller.unlockedThemes.isEmpty &&
                controller.unlockedEntryEffects.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No rewards unlocked yet. Level up to earn badges, themes, and effects!',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...controller.unlockedBadges.map((badge) {
                  return Chip(
                    avatar: const Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                    label: Text(badge['badgeName'] ?? 'Badge'),
                    backgroundColor: Colors.amber.withOpacity(0.1),
                  );
                }),
                ...controller.unlockedThemes.map((theme) {
                  return Chip(
                    avatar: const Icon(Icons.palette, size: 16, color: Colors.purple),
                    label: Text(theme['themeName'] ?? 'Theme'),
                    backgroundColor: Colors.purple.withOpacity(0.1),
                  );
                }),
                ...controller.unlockedEntryEffects.map((effect) {
                  return Chip(
                    avatar: const Icon(Icons.animation, size: 16, color: Colors.cyan),
                    label: Text(effect['effectName'] ?? 'Effect'),
                    backgroundColor: Colors.cyan.withOpacity(0.1),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialTab() {
    return Column(
      children: [
        Obx(() => Container(
              padding: const EdgeInsets.all(12),
              color: Colors.deepPurple.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSocialStat('Followers', controller.followerCount.value),
                  _buildSocialStat('Admins', controller.adminCount.value),
                  _buildSocialStat('Online', controller.onlineCount.value),
                ],
              ),
            )),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Followers'),
                    Tab(text: 'Admins'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildFollowersList(),
                      _buildAdminsList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialStat(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFollowersList() {
    return Obx(() {
      if (controller.followers.isEmpty) {
        return const Center(
          child: Text('No followers yet'),
        );
      }
      return ListView.builder(
        itemCount: controller.followers.length,
        itemBuilder: (context, index) {
          final follower = controller.followers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: follower['userAvatar'] != null && follower['userAvatar'].isNotEmpty
                  ? NetworkImage(follower['userAvatar'])
                  : null,
              child: follower['userAvatar'] == null || follower['userAvatar'].isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(follower['userName'] ?? 'User'),
            subtitle: Text('Role: ${follower['role'] ?? 'member'}'),
            trailing: follower['role'] != 'admin'
                ? IconButton(
                    icon: const Icon(Icons.admin_panel_settings, color: Colors.deepPurple),
                    onPressed: () {
                      controller.promoteToAdmin(widget.roomId, follower['userId']);
                      Get.snackbar(
                        'Success',
                        'Promoted to admin',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                  )
                : null,
          );
        },
      );
    });
  }

  Widget _buildAdminsList() {
    return Obx(() {
      if (controller.admins.isEmpty) {
        return const Center(
          child: Text('No admins yet'),
        );
      }
      return ListView.builder(
        itemCount: controller.admins.length,
        itemBuilder: (context, index) {
          final admin = controller.admins[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: admin['userAvatar'] != null && admin['userAvatar'].isNotEmpty
                  ? NetworkImage(admin['userAvatar'])
                  : null,
              child: admin['userAvatar'] == null || admin['userAvatar'].isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(admin['userName'] ?? 'Admin'),
            subtitle: Text('Promoted: ${admin['promotedAt'] != null ? DateTime.parse(admin['promotedAt']).toString().split(' ')[0] : 'N/A'}'),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                controller.demoteAdmin(widget.roomId, admin['userId']);
                Get.snackbar(
                  'Success',
                  'Admin demoted',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildNoticesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => const Text(
                'Welcome Message',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
          const SizedBox(height: 8),
          Obx(() => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Text(
                  controller.welcomeMessage.value.isEmpty
                      ? 'No welcome message set'
                      : controller.welcomeMessage.value,
                  style: TextStyle(
                    color: controller.welcomeMessage.value.isEmpty ? Colors.grey : Colors.blueGrey,
                  ),
                ),
              )),
          const SizedBox(height: 20),
          const Text(
            'Announcement',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Text(
                  controller.announcement.value.isEmpty
                      ? 'No announcement'
                      : controller.announcement.value,
                  style: TextStyle(
                    color: controller.announcement.value.isEmpty ? Colors.grey : Colors.orangeAccent,
                  ),
                ),
              )),
          const SizedBox(height: 20),
          const Text(
            'Pinned Message',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Text(
                  controller.pinnedMessage.value.isEmpty
                      ? 'No pinned message'
                      : controller.pinnedMessage.value,
                  style: TextStyle(
                    color: controller.pinnedMessage.value.isEmpty ? Colors.grey : Colors.green,
                  ),
                ),
              )),
          const SizedBox(height: 20),
          const Text(
            'Topic',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Text(
                  controller.topic.value.isEmpty ? 'No topic set' : controller.topic.value,
                  style: TextStyle(
                    color: controller.topic.value.isEmpty ? Colors.grey : Colors.purple,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'By Gifts'),
              Tab(text: 'By Level'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildGiftLeaderboard(),
                _buildLevelLeaderboard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftLeaderboard() {
    return FutureBuilder(
      future: controller.getLeaderboard('daily'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final leaderboard = snapshot.data ?? [];
        if (leaderboard.isEmpty) {
          return const Center(child: Text('No leaderboard data yet'));
        }
        return ListView.builder(
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final room = leaderboard[index];
            final rank = index + 1;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: rank <= 3 ? Colors.amber : Colors.grey[300],
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: rank <= 3 ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                title: Text(room['roomName'] ?? 'Unknown'),
                subtitle: Text('Owner: ${room['ownerName'] ?? 'Unknown'}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${room['totalGiftValue'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${room['totalGifts'] ?? 0} gifts',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLevelLeaderboard() {
    return FutureBuilder(
      future: controller.getLevelLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final leaderboard = snapshot.data ?? [];
        if (leaderboard.isEmpty) {
          return const Center(child: Text('No level leaderboard data yet'));
        }
        return ListView.builder(
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final room = leaderboard[index];
            final rank = index + 1;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: rank <= 3 ? Colors.purple : Colors.grey[300],
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: rank <= 3 ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                title: Text(room['roomName'] ?? 'Unknown'),
                subtitle: Text('Owner: ${room['ownerName'] ?? 'Unknown'}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Level ${room['level'] ?? 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${room['totalXp'] ?? 0} XP',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    controller.joinRoom(widget.roomId, widget.userId, userName: widget.userName, userAvatar: widget.userAvatar);
  }

  @override
  void dispose() {
    controller.leaveRoom();
    super.dispose();
  }
}