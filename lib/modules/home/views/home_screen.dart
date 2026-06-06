import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/home_controller.dart';
import '../../room/views/create_room_screen.dart';
import '../../room/views/live_room_screen.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => AppBar(
              title: controller.isSearching.value
                  ? TextField(
                      controller: controller.searchController,
                      style: const TextStyle(color: Colors.white),
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search for rooms or tags...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) => controller.searchRooms(value),
                    )
                  : const Text('Discover Rooms',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(
                    controller.isSearching.value ? Icons.close : Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    controller.toggleSearch();
                  },
                )
              ],
            )),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC107)));
        }

        if (controller.liveRooms.isEmpty) {
          return const Center(
            child: Text(
                'No live rooms right now.\nBe the first to start a party!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16)),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchLiveRooms,
          color: const Color(0xFFFFC107),
          backgroundColor: Colors.black87,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: controller.liveRooms.length,
            itemBuilder: (context, index) {
              var room = controller.liveRooms[index];
              return _buildRoomCard(room);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFC107),
        onPressed: () {
          Get.to(() => CreateRoomScreen());
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    return GestureDetector(
      onTap: () {
        Get.to(() => LiveRoomScreen(room: room));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white12),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Image
            CachedNetworkImage(
              imageUrl:
                  (room['coverImage'] != null && room['coverImage'].isNotEmpty)
                      ? room['coverImage']
                      : 'https://via.placeholder.com/300x300.png?text=Party',
              fit: BoxFit.cover,
            ),
            // Gradient overlay for text readability
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            // Room Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room['name'] ?? 'Party Room',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.headset_mic,
                        color: Color(0xFFFFC107), size: 14),
                    const SizedBox(width: 4),
                    Text('${room['activeUsers'] ?? 0} partying',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12))
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
