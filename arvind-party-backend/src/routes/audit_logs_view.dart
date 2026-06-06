import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../core/constants/api_constants.dart';

class AuditLogsView extends StatefulWidget {
  const AuditLogsView({super.key});

  @override
  State<AuditLogsView> createState() => _AuditLogsViewState();
}

class _AuditLogsViewState extends State<AuditLogsView> {
  bool _isLoading = true;
  List<dynamic> _logs = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final token = GetStorage().read('staff_token');
      final response = await http.get(
        Uri.parse('${ApiConstants.apiBaseUrl}/treasury/logs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _logs = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch logs');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Treasury Audit Logs',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _fetchLogs,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('Refresh',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15141F),
                    side: const BorderSide(color: Color(0xFFFF8906)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'History of all coins generated securely by Owner accounts.',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFF8906)))
                  : _errorMessage != null
                      ? Center(
                          child: Text(_errorMessage!,
                              style: const TextStyle(color: Colors.redAccent)))
                      : _logs.isEmpty
                          ? const Center(
                              child: Text('No audit logs found.',
                                  style: TextStyle(color: Colors.white54)))
                          : SingleChildScrollView(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DataTable(
                                  headingRowColor:
                                      WidgetStateProperty.all(Colors.black38),
                                  columns: const [
                                    DataColumn(
                                        label: Text('Date & Time',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFF8906)))),
                                    DataColumn(
                                        label: Text('Amount Minted',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.yellow))),
                                    DataColumn(
                                        label: Text('Reason / Memo',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFF8906)))),
                                    DataColumn(
                                        label: Text('Generated By',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFF8906)))),
                                  ],
                                  rows: _logs.map((log) {
                                    final date = DateTime.tryParse(
                                            log['createdAt'] ?? '')
                                        ?.toLocal();
                                    final formattedDate = date != null
                                        ? DateFormat('dd MMM yyyy, hh:mm a')
                                            .format(date)
                                        : 'Unknown';

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(formattedDate,
                                            style: const TextStyle(
                                                color: Colors.white70))),
                                        DataCell(Text(
                                            '+ ${log['amount'].toString()}',
                                            style: const TextStyle(
                                                color: Colors.greenAccent,
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text(
                                            log['reason']?.toString() ?? '-',
                                            style: const TextStyle(
                                                color: Colors.white70))),
                                        DataCell(Text(
                                            log['generatedBy']?.toString() ??
                                                'OWNER.WEB',
                                            style: const TextStyle(
                                                color: Colors.white70))),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
