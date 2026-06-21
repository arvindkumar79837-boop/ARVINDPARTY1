// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/widgets/transaction_item.dart
// ARVIND PARTY - TRANSACTION ITEM WIDGET
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (transaction.type) {
      case TransactionType.recharge:
        icon = Icons.add_circle;
        iconColor = Colors.green;
        break;
      case TransactionType.withdraw:
        icon = Icons.arrow_circle_right;
        iconColor = Colors.red;
        break;
      case TransactionType.giftSent:
        icon = Icons.card_giftcard;
        iconColor = Colors.purple;
        break;
      case TransactionType.giftReceived:
        icon = Icons.card_giftcard;
        iconColor = Colors.orange;
        break;
      case TransactionType.eventReward:
        icon = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case TransactionType.system:
        icon = Icons.settings;
        iconColor = Colors.grey;
        break;
    }

    String currencyLabel;
    switch (transaction.currency) {
      case CurrencyType.coins:
        currencyLabel = 'Coins';
        break;
      case CurrencyType.diamonds:
        currencyLabel = 'Diamonds';
        break;
      case CurrencyType.beans:
        currencyLabel = 'Rewards';
        break;
    }

    String statusLabel;
    Color statusColor;
    switch (transaction.status) {
      case TransactionStatus.pending:
        statusLabel = 'Pending';
        statusColor = Colors.orange;
        break;
      case TransactionStatus.completed:
        statusLabel = 'Completed';
        statusColor = Colors.green;
        break;
      case TransactionStatus.failed:
        statusLabel = 'Failed';
        statusColor = Colors.red;
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        transaction.description ?? transaction.type.name.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${_formatDate(transaction.createdAt)}  •  $statusLabel',
        style: TextStyle(color: statusColor, fontSize: 12),
      ),
      trailing: Text(
        '${transaction.type == TransactionType.withdraw ? '-' : '+'}${transaction.amount} $currencyLabel',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: transaction.type == TransactionType.withdraw ? Colors.red : Colors.green,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}