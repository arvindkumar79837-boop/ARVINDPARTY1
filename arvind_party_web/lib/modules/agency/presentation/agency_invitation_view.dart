import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class AgencyInvitationView extends StatefulWidget {
  const AgencyInvitationView({super.key});

  @override
  State<AgencyInvitationView> createState() => _AgencyInvitationViewState();
}

class _AgencyInvitationViewState extends State<AgencyInvitationView> {
  final ApiService _apiService = Get.find<ApiService>();
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool isLoading = false;
  List<dynamic> invitations = [];
  int pendingCount = 0;

  @override
  void initState() {
    super.initState();
    fetchInbox();
  }

  Future<void> fetchInbox() async {
    setState(() => isLoading = true);
    try {
      final response = await _apiService.get('/agency/invitations/inbox');
      if (response['success'] == true) {
        setState(() {
          invitations = List<dynamic>.from(response['data'] ?? []);
          pendingCount = response['count'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Fetch inbox error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> sendInvitation() async {
    final uid = _uidController.text.trim();
    final message = _messageController.text.trim();
    if (uid.isEmpty) {
      Get.snackbar('Error', 'Please enter a valid UID');
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await _apiService.post('/agency/invitations/send', {
        'targetUid': uid,
        'message': message,
        'specialRoles': {},
      });
      if (response['success'] == true) {
        Get.snackbar('Success', 'Invitation sent successfully');
        _uidController.clear();
        _messageController.clear();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to send invitation');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send invitation');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    setState(() => isLoading = true);
    try {
      final response = await _apiService.post('/agency/invitations/accept/$invitationId', {});
      if (response['success'] == true) {
        Get.snackbar('Success', 'Invitation accepted! Welcome to the agency.');
        fetchInbox();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to accept invitation');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept invitation');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> rejectInvitation(String invitationId) async {
    setState(() => isLoading = true);
    try {
      final response = await _apiService.post('/agency/invitations/reject/$invitationId', {});
      if (response['success'] == true) {
        Get.snackbar('Rejected', 'Invitation rejected');
        fetchInbox();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to reject invitation');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject invitation');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agency & Inbox'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Send invitation card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Send Agency Invitation',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _uidController,
                      decoration: const InputDecoration(
                        labelText: 'Enter User UID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_search),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.message),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : sendInvitation,
                        icon: const Icon(Icons.send),
                        label: const Text('Send Invitation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Inbox header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inbox (Pending)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$pendingCount',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isLoading && invitations.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : invitations.isEmpty
                      ? Center(child: Text('No pending invitations'))
                      : ListView.builder(
                          itemCount: invitations.length,
                          itemBuilder: (context, index) {
                            final invitation = invitations[index];
                            final agencyName = invitation['agencyName'] ?? 'Unknown Agency';
                            final message = invitation['message'] ?? '';
                            final createdAt = invitation['createdAt'] ?? '';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  child: Text(
                                    agencyName[0].toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text('Invitation from $agencyName'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (message.isNotEmpty) Text(message),
                                    Text(
                                      'Received: $createdAt',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check_circle, color: Colors.green),
                                      onPressed: () => acceptInvitation(invitation['_id']),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () => rejectInvitation(invitation['_id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _uidController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}