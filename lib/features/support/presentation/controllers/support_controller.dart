// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/support/presentation/controllers/support_controller.dart
// ARVIND PARTY - SUPPORT & TICKETING CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final selectedFaqIndex = Rxn<int>();
  final expandedFaqIds = <int>[].obs;

  // FAQ Data
  final faqs = <FaqItem>[].obs;

  // Ticket data
  final tickets = <SupportTicket>[].obs;
  final selectedTicket = Rxn<SupportTicket>();
  final ticketSubject = ''.obs;
  final ticketCategory = 'technical'.obs;
  final ticketDescription = ''.obs;
  final ticketPriority = 'medium'.obs;
  final isSubmitting = false.obs;
  final submitSuccess = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFaqs();
    loadTickets();
  }

  void loadFaqs() {
    try {
      faqs.value = [
        FaqItem(0, 'How do I create a voice room?',
            'To create a voice room, tap the "+" icon on the Home screen, select "Create Room", customize your room settings (name, password, max members), and tap "Create". You can then invite friends or open it to the public.'),
        FaqItem(1, 'How do I purchase coins/diamonds?',
            'Go to your Wallet from the menu, select "Recharge", choose your preferred package (Coins or Diamonds), and complete the payment via UPI, net banking, or wallet transfer. The amount will be credited instantly.'),
        FaqItem(2, 'How does the VIP system work?',
            'VIP has 5 tiers - Silver, Gold, Platinum, Diamond, and Legend. Each tier unlocks exclusive benefits like special badges, entry effects, increased daily rewards, and priority support. You can upgrade by purchasing VIP subscription from the VIP section.'),
        FaqItem(3, 'How do I send gifts to other users?',
            'While in a voice room, tap the gift icon on any user\'s avatar. Select your gift from the shop, choose quantity if applicable, and tap "Send". Animated gifts will trigger special effects in the room.'),
        FaqItem(4, 'How do I report a user or issue?',
            'Tap on the user\'s profile, select the three-dot menu, choose "Report", select the reason for reporting, and optionally add screenshots. Our moderation team will review the report within 24 hours.'),
        FaqItem(5, 'How do I withdraw my earnings?',
            'Go to Wallet > Withdrawal, enter the amount you wish to withdraw (minimum withdrawal applies), select your withdrawal method (UPI, Bank Transfer), and confirm. Processing takes 24-48 hours.'),
        FaqItem(6, 'What are Family Wars and how do I participate?',
            'Family Wars are competitive events where families compete in various challenges. Join or create a family, participate in weekly events, earn points for your family, and win exclusive rewards. Access from the Family section.'),
        FaqItem(7, 'How do I claim mission rewards?',
            'Open the Missions section from your profile. Complete the required tasks (e.g., send 5 gifts, host a room for 1 hour). Once completed, tap "Claim" to receive your rewards instantly.'),
      ];
    } catch (e) {
      errorMessage.value = 'Failed to load FAQs: $e';
    }
  }

  void loadTickets() {
    try {
      tickets.value = [
        SupportTicket('TK-001', 'Payment issue', 'technical', 'high', 'open',
            DateTime.now().subtract(const Duration(hours: 2)),
            'Cannot complete coin purchase via UPI'),
        SupportTicket('TK-002', 'Room creation error', 'technical', 'medium', 'in_progress',
            DateTime.now().subtract(const Duration(days: 1)),
            'Getting error when creating password-protected room'),
        SupportTicket('TK-003', 'Account verification', 'account', 'low', 'resolved',
            DateTime.now().subtract(const Duration(days: 3)),
            'Please verify my phone number'),
      ];
    } catch (e) {
      errorMessage.value = 'Failed to load tickets: $e';
    }
  }

  void toggleFaq(int index) {
    if (expandedFaqIds.contains(index)) {
      expandedFaqIds.remove(index);
    } else {
      expandedFaqIds.add(index);
    }
  }

  bool isFaqExpanded(int index) => expandedFaqIds.contains(index);

  void setTicketCategory(String category) {
    ticketCategory.value = category;
  }

  void setTicketPriority(String priority) {
    ticketPriority.value = priority;
  }

  void updateSubject(String value) {
    ticketSubject.value = value;
  }

  void updateDescription(String value) {
    ticketDescription.value = value;
  }

  void submitTicket() {
    try {
      if (ticketSubject.value.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter a subject',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (ticketDescription.value.trim().isEmpty) {
        Get.snackbar('Error', 'Please describe your issue',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      isSubmitting.value = true;
      submitSuccess.value = false;

      // Simulate API call
      final newTicket = SupportTicket(
        'TK-${(tickets.length + 1).toString().padLeft(3, '0')}',
        ticketSubject.value,
        ticketCategory.value,
        ticketPriority.value,
        'open',
        DateTime.now(),
        ticketDescription.value,
      );

      tickets.insert(0, newTicket);

      ticketSubject.value = '';
      ticketDescription.value = '';
      ticketCategory.value = 'technical';
      ticketPriority.value = 'medium';

      submitSuccess.value = true;
      Get.snackbar('Success', 'Ticket #${newTicket.id} created successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFFF9800), colorText: Colors.white);
    } catch (e) {
      errorMessage.value = 'Failed to submit ticket: $e';
      Get.snackbar('Error', 'Failed to submit ticket. Please try again.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  void selectTicket(SupportTicket ticket) {
    selectedTicket.value = ticket;
  }

  String get priorityLabel => ticketPriority.value == 'low'
      ? 'Low'
      : ticketPriority.value == 'medium'
          ? 'Medium'
          : ticketPriority.value == 'high'
              ? 'High'
              : 'Urgent';

  List<SupportTicket> get openTickets =>
      tickets.where((t) => t.status == 'open').toList();
  List<SupportTicket> get inProgressTickets =>
      tickets.where((t) => t.status == 'in_progress').toList();
  List<SupportTicket> get resolvedTickets =>
      tickets.where((t) => t.status == 'resolved').toList();

  @override
  void onClose() {
    super.onClose();
  }
}

class FaqItem {
  final int id;
  final String question;
  final String answer;

  FaqItem(this.id, this.question, this.answer);
}

class SupportTicket {
  final String id;
  final String subject;
  final String category;
  final String priority;
  final String status; // open, in_progress, resolved
  final DateTime createdAt;
  final String description;

  const SupportTicket(
    this.id,
    this.subject,
    this.category,
    this.priority,
    this.status,
    this.createdAt,
    this.description,
  );

  String get categoryLabel {
    switch (category) {
      case 'technical': return 'Technical';
      case 'payment': return 'Payment';
      case 'account': return 'Account';
      case 'report': return 'Report';
      case 'other': return 'Other';
      default: return category;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'open': return 'Open';
      case 'in_progress': return 'In Progress';
      case 'resolved': return 'Resolved';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'open': return const Color(0xFFFF9800);
      case 'in_progress': return const Color(0xFF2196F3);
      case 'resolved': return const Color(0xFF4CAF50);
      default: return Colors.white54;
    }
  }
}