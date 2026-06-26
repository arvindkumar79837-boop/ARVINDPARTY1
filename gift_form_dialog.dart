import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'gifts_controller.dart';

class GiftFormDialog extends StatefulWidget {
  final Gift? gift;

  const GiftFormDialog({Key? key, this.gift}) : super(key: key);

  @override
  State<GiftFormDialog> createState() => _GiftFormDialogState();
}

class _GiftFormDialogState extends State<GiftFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final GiftsController controller = Get.find();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _diamondController;
  late final TextEditingController _typeController;
  late final TextEditingController _categoryController;

  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift?.giftName ?? '');
    _priceController = TextEditingController(text: widget.gift?.coinPrice.toString() ?? '');
    _diamondController = TextEditingController(text: widget.gift?.diamondValue.toString() ?? '');
    _typeController = TextEditingController(text: widget.gift?.giftType ?? 'STATIC');
    _categoryController = TextEditingController(text: widget.gift?.category ?? 'BASIC');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _diamondController.dispose();
    _typeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.gift == null) {
        controller.createGift(
          giftName: _nameController.text,
          coinPrice: int.tryParse(_priceController.text) ?? 0,
          diamondValue: int.tryParse(_diamondController.text) ?? 0,
          giftType: _typeController.text,
          category: _categoryController.text,
          imageBytes: _imageBytes,
          imageName: _imageName,
        );
      } else {
        controller.updateGift(
          widget.gift!.id,
          giftName: _nameController.text,
          coinPrice: int.tryParse(_priceController.text) ?? 0,
          diamondValue: int.tryParse(_diamondController.text) ?? 0,
          giftType: _typeController.text,
          imageBytes: _imageBytes,
          imageName: _imageName,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = widget.gift == null;
    return AlertDialog(
      title: Text(isCreating ? 'Create Gift' : 'Edit Gift'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Gift Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Coin Price'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Enter coin price';
                        if (int.tryParse(value) == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _diamondController,
                      decoration: const InputDecoration(labelText: 'Diamond Value'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Enter diamond value';
                        if (int.tryParse(value) == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(labelText: 'Gift Type'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _imageBytes != null
                        ? Image.memory(_imageBytes!, height: 60)
                        : (widget.gift?.previewImageUrl != null && widget.gift!.previewImageUrl.isNotEmpty)
                            ? Image.network(widget.gift!.previewImageUrl, height: 60)
                            : const Text('No image selected.'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: _pickImage,
                    tooltip: 'Select Image',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Obx(() => controller.isLoading.value
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(isCreating ? 'Create' : 'Update')),
        ),
      ],
    );
  }
}