import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '.././controllers/gift_controller.dart';
import '.././widgets/gift_card.dart';
import '.././widgets/gift_picker_dialog.dart';

class GiftScreen extends GetView<GiftController> {
  const GiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GiftController());
    return Scaffold(
      appBar: AppBar(title: const Text('Gift Shop', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0,
        actions: [Obx(() => Padding(padding: const EdgeInsets.only(right: 16), child: Row(children: [const Icon(Icons.monetization_on, color: Colors.orange), Text(' ${controller.gifts.length}', style: const TextStyle(fontWeight: FontWeight.bold))])))],
      ),
      body: Column(children: [
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
            if (controller.gifts.isEmpty) return const Center(child: Text('No gifts available', style: TextStyle(color: Colors.grey)));
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemCount: controller.gifts.length,
              itemBuilder: (context, index) {
                final gift = controller.gifts[index];
                return GiftCard(gift: gift, onTap: () {
                  Get.dialog(GiftPickerDialog(receiverId: 'demo_user_id', receiverName: 'Demo User', roomId: Get.arguments?['roomId'] ?? ''));
                });
              },
            );
          }),
        ),
      ]),
    );
  }
}
