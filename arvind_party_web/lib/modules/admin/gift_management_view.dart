// ═══════════════════════════════════════════════════════════════════════════
// MODULE: Admin Gift Management Dashboard
// ARVIND PARTY - Web Admin Panel
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class GiftManagementView extends GetView<GiftManagementController> {
  const GiftManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Management'),
        backgroundColor: Colors.pink[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.showAddGiftDialog,
            tooltip: 'Add Gift',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadGifts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.gifts.isEmpty) {
                return const Center(child: Text('No gifts found', style: TextStyle(color: Colors.grey)));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.gifts.length,
                itemBuilder: (context, index) => _buildGiftCard(controller.gifts[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.pink[50],
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total Gifts', controller.totalGifts.toString(), Colors.pink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Active', controller.activeGifts.toString(), Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Total Value', '${controller.totalValue}', Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildGiftCard(Map<String, dynamic> gift) {
    final giftId = gift['_id'] ?? '';
    final name = gift['name'] ?? 'Unknown Gift';
    final icon = gift['icon'] ?? '🎁';
    final coinPrice = gift['coinPrice'] ?? 0;
    final diamondPrice = gift['diamondPrice'] ?? 0;
    final isActive = gift['isActive'] ?? true;
    final description = gift['description'] ?? '';
    final createdAt = gift['createdAt'] != null 
        ? DateTime.parse(gift['createdAt']).toString().split(' ')[0]
        : 'N/A';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (coinPrice > 0)
                  Chip(
                    label: Text('$coinPrice Coins', style: const TextStyle(fontSize: 10)),
                    backgroundColor: Colors.blue[100],
                  ),
                if (diamondPrice > 0)
                  Chip(
                    label: Text('$diamondPrice 💎', style: const TextStyle(fontSize: 10)),
                    backgroundColor: Colors.purple[100],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (action) {
                    if (action == 'edit') {
                      controller.showEditGiftDialog(gift);
                    } else if (action == 'toggle') {
                      controller.toggleGiftStatus(giftId, !isActive);
                    } else if (action == 'delete') {
                      controller.deleteGift(giftId);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(isActive ? 'Deactivate' : 'Activate'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GiftManagementController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxList<Map<String, dynamic>> gifts = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt totalGifts = 0.obs;
  final RxInt activeGifts = 0.obs;
  final RxInt totalValue = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadGifts();
  }

  Future<void> loadGifts() async {
    isLoading.value = true;
    try {
      final response = await _api.get('/api/admin/gifts');
      if (response['success'] == true) {
        final data = response['data'] as List;
        gifts.assignAll(data.map((e) => Map<String, dynamic>.from(e)).toList());
        totalGifts.value = data.length;
        activeGifts.value = gifts.where((g) => g['isActive'] == true).length;
        totalValue.value = gifts.fold<int>(0, (sum, g) => sum + ((g['coinPrice'] ?? 0) as int));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load gifts: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void showAddGiftDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final coinPriceController = TextEditingController();
    final diamondPriceController = TextEditingController();
    final iconController = TextEditingController(text: '🎁');

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Gift'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Gift Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(labelText: 'Emoji Icon', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: coinPriceController,
                      decoration: const InputDecoration(labelText: 'Coin Price', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: diamondPriceController,
                      decoration: const InputDecoration(labelText: 'Diamond Price', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                Get.snackbar('Error', 'Gift name is required', backgroundColor: Colors.red);
                return;
              }

              try {
                final response = await _api.post('/api/admin/gifts', {
                  'name': name,
                  'icon': iconController.text,
                  'description': descriptionController.text,
                  'coinPrice': int.tryParse(coinPriceController.text) ?? 0,
                  'diamondPrice': int.tryParse(diamondPriceController.text) ?? 0,
                  'isActive': true,
                });

                if (response['success'] == true) {
                  Get.back();
                  Get.snackbar('Success', 'Gift created', backgroundColor: Colors.green);
                  loadGifts();
                } else {
                  Get.snackbar('Error', response['message'] ?? 'Failed to create gift', backgroundColor: Colors.red);
                }
              } catch (e) {
                Get.snackbar('Error', 'Operation failed: $e', backgroundColor: Colors.red);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void showEditGiftDialog(Map<String, dynamic> gift) {
    final nameController = TextEditingController(text: gift['name'] ?? '');
    final descriptionController = TextEditingController(text: gift['description'] ?? '');
    final coinPriceController = TextEditingController(text: (gift['coinPrice'] ?? 0).toString());
    final diamondPriceController = TextEditingController(text: (gift['diamondPrice'] ?? 0).toString());
    final iconController = TextEditingController(text: gift['icon'] ?? '🎁');

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Gift'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Gift Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(labelText: 'Emoji Icon', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: coinPriceController,
                      decoration: const InputDecoration(labelText: 'Coin Price', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: diamondPriceController,
                      decoration: const InputDecoration(labelText: 'Diamond Price', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await _api.put('/api/admin/gifts/${gift['_id']}', {
                  'name': nameController.text,
                  'icon': iconController.text,
                  'description': descriptionController.text,
                  'coinPrice': int.tryParse(coinPriceController.text) ?? 0,
                  'diamondPrice': int.tryParse(diamondPriceController.text) ?? 0,
                });

                if (response['success'] == true) {
                  Get.back();
                  Get.snackbar('Success', 'Gift updated', backgroundColor: Colors.green);
                  loadGifts();
                } else {
                  Get.snackbar('Error', response['message'] ?? 'Failed to update gift', backgroundColor: Colors.red);
                }
              } catch (e) {
                Get.snackbar('Error', 'Operation failed: $e', backgroundColor: Colors.red);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> toggleGiftStatus(String giftId, bool isActive) async {
    try {
      final response = await _api.put('/api/admin/gifts/$giftId', {'isActive': isActive});
      if (response['success'] == true) {
        Get.snackbar('Success', isActive ? 'Gift activated' : 'Gift deactivated', backgroundColor: Colors.green);
        loadGifts();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to update gift', backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.snackbar('Error', 'Operation failed: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> deleteGift(String giftId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Gift'),
        content: const Text('Are you sure you want to delete this gift? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await _api.delete('/api/admin/gifts/$giftId');
      if (response['success'] == true) {
        Get.snackbar('Success', 'Gift deleted', backgroundColor: Colors.green, colorText: Colors.black);
        loadGifts();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to delete gift', backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.snackbar('Error', 'Operation failed: $e', backgroundColor: Colors.red);
    }
  }
}