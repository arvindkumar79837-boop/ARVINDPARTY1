import 'package:flutter/material.dart';

class SocialLinksScreen extends StatelessWidget {
  const SocialLinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Social Links'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTile(Icons.g_mobiledata, 'Google', 'Connect'),
          _buildTile(Icons.facebook, 'Facebook', 'Connect'),
          _buildTile(Icons.apple, 'Apple', 'Connect'),
          _buildTile(Icons.camera_alt, 'Instagram', 'Connect'),
          _buildTile(Icons.smart_display, 'YouTube', 'Connect'),
        ],
      ),
    );
  }

  static Widget _buildTile(IconData icon, String title, String action) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 28),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: TextButton(
        onPressed: () {},
        child: Text(action, style: const TextStyle(color: Color(0xFFFFC107))),
      ),
    );
  }
}
