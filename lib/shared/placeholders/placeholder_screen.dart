import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaceholderScreen extends StatelessWidget {
  final String routeName;
  const PlaceholderScreen({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Placeholder: $routeName')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              'Route "$routeName" is under construction!',
              textAlign: TextAlign.center,
              style: Get.textTheme.titleLarge?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              'Please implement this screen.',
              style: Get.textTheme.bodyMedium?.copyWith(color: Colors.white54),
            ),
             const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}