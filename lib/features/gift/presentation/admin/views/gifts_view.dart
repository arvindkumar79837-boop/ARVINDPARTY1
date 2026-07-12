import 'package:arvind_party/features/gift/presentation/admin/controllers/gifts_controller.dart';
import 'package:arvind_party/features/gift/presentation/admin/views/gift_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GiftsView extends GetView<GiftsController> {
  const GiftsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Management'),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Image')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Price (Coins)')),
              DataColumn(label: Text('Actions')),
            ],
            rows: controller.gifts.map((gift) {
              return DataRow(cells: [
                DataCell(Image.network(gift.previewImageUrl, width: 40, height: 40, errorBuilder: (c, o, s) => const SizedBox(width: 40, height: 40, child: Icon(Icons.card_giftcard)))),
                DataCell(Text(gift.giftName)),
                DataCell(Text('${gift.coinPrice} coins')),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Get.dialog(GiftFormDialog(gift: gift));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Delete Gift',
                          middleText:
                              'Are you sure you want to delete "${gift.giftName}"?',
                          textConfirm: 'Delete',
                          textCancel: 'Cancel',
                          confirmTextColor: Colors.white,
                          onConfirm: () async {
                            await controller.deleteGift(gift.id);
                          },
                        );
                      },
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.dialog(const GiftFormDialog());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}