// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/support/presentation/views/support_screen.dart
// ARVIND PARTY - SUPPORT & TICKETING SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/support_controller.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SupportController controller = Get.find<SupportController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Help & Support',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF9800),
            labelColor: Color(0xFFFF9800),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.help_outline), text: 'FAQ'),
              Tab(icon: Icon(Icons.add_circle_outline), text: 'New Ticket'),
              Tab(icon: Icon(Icons.list_alt), text: 'My Tickets'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFaqTab(controller),
            _buildNewTicketTab(controller),
            _buildMyTicketsTab(controller),
          ],
        ),
      ),
    );
  }

  // ─── FAQ TAB ──────────────────────────────────────────────────────────

  Widget _buildFaqTab(SupportController controller) {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.faqs.length,
          itemBuilder: (context, index) {
            final faq = controller.faqs[index];
            final isExpanded = controller.isFaqExpanded(index);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A4E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isExpanded
                      ? const Color(0xFFFF9800).withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => controller.toggleFaq(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              faq.question,
                              style: TextStyle(
                                color: isExpanded ? const Color(0xFFFF9800) : Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: isExpanded ? const Color(0xFFFF9800) : Colors.white54,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        faq.answer,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ));
  }

  // ─── NEW TICKET TAB ───────────────────────────────────────────────────

  Widget _buildNewTicketTab(SupportController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A4E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit a Ticket',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Our team will respond within 24 hours',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                ),
                const SizedBox(height: 20),
                // Subject
                const Text('Subject *', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Obx(() => TextField(
                      onChanged: controller.updateSubject,
                      decoration: InputDecoration(
                        hintText: 'Brief title for your issue',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                        filled: true,
                        fillColor: const Color(0xFF1A1A2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    )),
                const SizedBox(height: 16),
                // Category
                const Text('Category', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Obx(() => Row(
                      children: [
                        _buildCategoryChip(controller, 'Technical', 'technical'),
                        const SizedBox(width: 8),
                        _buildCategoryChip(controller, 'Payment', 'payment'),
                        const SizedBox(width: 8),
                        _buildCategoryChip(controller, 'Account', 'account'),
                      ],
                    )),
                const SizedBox(height: 8),
                Obx(() => Row(
                      children: [
                        _buildCategoryChip(controller, 'Report', 'report'),
                        const SizedBox(width: 8),
                        _buildCategoryChip(controller, 'Other', 'other'),
                      ],
                    )),
                const SizedBox(height: 16),
                // Priority
                const Text('Priority', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Obx(() => Row(
                      children: [
                        _buildPriorityChip(controller, 'Low', 'low', Colors.green),
                        const SizedBox(width: 8),
                        _buildPriorityChip(controller, 'Medium', 'medium', const Color(0xFFFF9800)),
                        const SizedBox(width: 8),
                        _buildPriorityChip(controller, 'High', 'high', Colors.red),
                      ],
                    )),
                const SizedBox(height: 16),
                // Description
                const Text('Description *', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Obx(() => TextField(
                      onChanged: controller.updateDescription,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Describe your issue in detail...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                        filled: true,
                        fillColor: const Color(0xFF1A1A2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    )),
                const SizedBox(height: 24),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isSubmitting.value ? null : controller.submitTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Text('Submit Ticket', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16)),
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(SupportController controller, String label, String value) {
    return Obx(() => GestureDetector(
          onTap: () => controller.setTicketCategory(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: controller.ticketCategory.value == value
                  ? const Color(0xFFFF9800)
                  : const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: controller.ticketCategory.value == value
                    ? const Color(0xFFFF9800)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: controller.ticketCategory.value == value ? Colors.black : Colors.white70,
                fontWeight: controller.ticketCategory.value == value ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ));
  }

  Widget _buildPriorityChip(SupportController controller, String label, String value, Color color) {
    return Obx(() => GestureDetector(
          onTap: () => controller.setTicketPriority(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: controller.ticketPriority.value == value
                  ? color.withValues(alpha: 0.2)
                  : const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: controller.ticketPriority.value == value ? color : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: controller.ticketPriority.value == value ? color : Colors.white54,
                fontWeight: controller.ticketPriority.value == value ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ));
  }

  // ─── MY TICKETS TAB ───────────────────────────────────────────────────

  Widget _buildMyTicketsTab(SupportController controller) {
    return Obx(() {
      if (controller.tickets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.support_agent, size: 64, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              const Text('No support tickets', style: TextStyle(color: Colors.white54)),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.tickets.length,
        itemBuilder: (context, index) {
          final ticket = controller.tickets[index];
          return _buildTicketCard(controller, ticket);
        },
      );
    });
  }

  Widget _buildTicketCard(SupportController controller, SupportTicket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ticket.statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                ticket.statusLabel,
                style: TextStyle(color: ticket.statusColor, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(ticket.id, style: const TextStyle(color: Color(0xFFFF9800), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            ticket.subject,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip('Category', ticket.categoryLabel),
              const SizedBox(width: 8),
              _buildInfoChip('Priority', ticket.priority),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.description,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Created: ${_formatDate(ticket.createdAt)}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}