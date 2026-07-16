import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Privacy'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildToggle('Show Online Status', true),
          _buildToggle('Show Last Seen', true),
          _buildToggle('Allow Direct Messages', true),
          _buildToggle('Show Profile to Visitors', false),
          _buildToggle('Enable Read Receipts', true),
          _buildToggle('Show Activity Status', false),
        ],
      ),
    );
  }

  static Widget _buildToggle(String title, bool initialValue) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: initialValue,
      onChanged: (_) {},
      activeColor: const Color(0xFFFFC107),
    );
  }
}
