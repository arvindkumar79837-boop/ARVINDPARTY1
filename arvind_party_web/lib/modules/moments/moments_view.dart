// ═══════════════════════════════════════════════════════════════════════════
// VIEW: MomentsView — View and delete user moments/posts
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class MomentsView extends StatefulWidget {
  const MomentsView({super.key});

  @override
  State<MomentsView> createState() => _MomentsViewState();
}

class _MomentsViewState extends State<MomentsView> {
  final _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> _moments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoments();
  }

  Future<void> _loadMoments() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/moments');
      if (response['success'] == true) {
        _moments = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _deleteMoment(String momentId) async {
    try {
      await _apiService.delete('/moments/$momentId');
      Get.snackbar('Success', 'Moment deleted', backgroundColor: Colors.green);
      _loadMoments();
    } catch (_) {
      Get.snackbar('Error', 'Delete failed', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moments')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _moments.isEmpty
              ? const Center(child: Text('No moments found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _moments.length,
                  itemBuilder: (ctx, i) {
                    final moment = _moments[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.article, color: Colors.deepOrange),
                        title: Text(moment['userId'] ?? 'Unknown'),
                        subtitle: Text('${moment['content'] ?? ''} | ${moment['createdAt'] ?? ''}'),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteMoment(moment['_id'])),
                      ),
                    );
                  },
                ),
    );
  }
}