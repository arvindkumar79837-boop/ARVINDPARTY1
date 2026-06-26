// ═══════════════════════════════════════════════════════════════════════════
// VIEW: SupportTicketsView — Support ticket management
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class SupportTicketsView extends StatefulWidget {
  const SupportTicketsView({super.key});

  @override
  State<SupportTicketsView> createState() => _SupportTicketsViewState();
}

class _SupportTicketsViewState extends State<SupportTicketsView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, String>{};
      if (_filter == 'open') queryParams['status'] = 'open';
      if (_filter == 'resolved') queryParams['status'] = 'resolved';

      final response = await _apiService.get('/api/support/tickets', queryParams: queryParams);
      if (response['success'] == true) {
        _tickets = List<Map<String, dynamic>>.from(response['tickets'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _replyTicket(String ticketId) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reply to Ticket'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Your reply'),
          maxLines: 5,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: null), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: controller.text), child: const Text('Send')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      try {
        await _apiService.post('/api/support/ticket/reply', {'id': ticketId, 'message': result});
        Get.snackbar('Success', 'Reply sent', backgroundColor: Colors.green);
        _loadTickets();
      } catch (_) {
        Get.snackbar('Error', 'Failed to send reply', backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canReply = _permService.hasPermission('support.reply');

    return Scaffold(
      appBar: AppBar(title: const Text('Support Tickets')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'open', label: Text('Open')),
                    ButtonSegment(value: 'resolved', label: Text('Resolved')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (v) { setState(() => _filter = v.first); _loadTickets(); },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tickets.isEmpty
                    ? const Center(child: Text('No tickets found'))
                    : ListView.builder(
                        itemCount: _tickets.length,
                        itemBuilder: (ctx, i) {
                          final ticket = _tickets[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: Icon(Icons.support_agent, color: ticket['status'] == 'open' ? Colors.orange : Colors.green),
                              title: Text(ticket['subject'] ?? 'No subject'),
                              subtitle: Text('User: ${ticket['userId'] ?? ''} | ${ticket['createdAt'] ?? ''}'),
                              trailing: canReply && ticket['status'] != 'resolved'
                                  ? ElevatedButton(onPressed: () => _replyTicket(ticket['_id']), child: const Text('Reply'))
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}