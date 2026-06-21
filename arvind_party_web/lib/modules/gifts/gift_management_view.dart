// ═══════════════════════════════════════════════════════════════════════════
// VIEW: GiftManagementView — Full gift CRUD for admin panel
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class GiftManagementView extends StatefulWidget {
  const GiftManagementView({super.key});

  @override
  State<GiftManagementView> createState() => _GiftManagementViewState();
}

class _GiftManagementViewState extends State<GiftManagementView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _gifts = [];
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _diamondCostController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _diamondCostController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadGifts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/gifts');
      if (response['success'] == true) {
        _gifts = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _addGift() async {
    final name = _nameController.text.trim();
    final diamondCost = int.tryParse(_diamondCostController.text);
    if (name.isEmpty || diamondCost == null || diamondCost <= 0) {
      Get.snackbar('Error', 'Name and valid diamond cost required', backgroundColor: Colors.red);
      return;
    }

    try {
      await _apiService.post('/gifts', {
        'name': name,
        'diamondCost': diamondCost,
        'imageUrl': _imageUrlController.text.trim(),
        'description': _descriptionController.text.trim(),
        'isActive': true,
      });
      Get.snackbar('Success', 'Gift created', backgroundColor: Colors.green);
      _nameController.clear();
      _diamondCostController.clear();
      _imageUrlController.clear();
      _descriptionController.clear();
      _loadGifts();
    } catch (_) {
      Get.snackbar('Error', 'Failed to create gift', backgroundColor: Colors.red);
    }
  }

  Future<void> _toggleGiftStatus(String giftId, bool currentStatus) async {
    try {
      await _apiService.put('/gifts/$giftId', {'isActive': !currentStatus});
      Get.snackbar('Success', currentStatus ? 'Gift deactivated' : 'Gift activated', backgroundColor: Colors.green);
      _loadGifts();
    } catch (_) {
      Get.snackbar('Error', 'Operation failed', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = _permService.hasPermission('gifts.edit');

    return Scaffold(
      appBar: AppBar(title: const Text('Gift Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canCreate) ...[
                    const Text('Create Gift', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Gift Name', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _diamondCostController, decoration: const InputDecoration(labelText: 'Diamond Cost', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(onPressed: _addGift, icon: const Icon(Icons.add), label: const Text('Create Gift')),
                    const SizedBox(height: 24),
                  ],
                  const Text('All Gifts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _gifts.isEmpty
                      ? const Text('No gifts found')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _gifts.length,
                          itemBuilder: (ctx, i) {
                            final gift = _gifts[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: gift['imageUrl'] != null && gift['imageUrl'].isNotEmpty
                                    ? Image.network(gift['imageUrl'], width: 40, fit: BoxFit.cover)
                                    : const Icon(Icons.card_giftcard),
                                title: Text(gift['name'] ?? 'Untitled'),
                                subtitle: Text('${gift['diamondCost']} diamonds | ${gift['isActive'] == true ? 'Active' : 'Inactive'}'),
                                trailing: canCreate
                                    ? IconButton(
                                        icon: Icon(gift['isActive'] == true ? Icons.visibility : Icons.visibility_off),
                                        onPressed: () => _toggleGiftStatus(gift['_id'], gift['isActive'] == true),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}