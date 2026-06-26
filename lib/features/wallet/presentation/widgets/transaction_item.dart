import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final iconData = _getIcon();
    final iconColor = _getColor();
    final currencyLabel = _getCurrencyLabel();
    final statusLabel = _getStatusLabel();
    final statusColor = _getStatusColor();
    final isCredit = transaction.amount > 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.1),
        child: Icon(iconData, color: iconColor),
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
        '${isCredit ? '+' : '-'}${transaction.amount} $currencyLabel',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isCredit ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (transaction.walletType) {
      case WalletType.coin:
        return Icons.monetization_on;
      case WalletType.diamond:
        return Icons.diamond;
      case WalletType.family:
        return Icons.group;
      case WalletType.agency:
        return Icons.business;
    }
  }

  Color _getColor() {
    if (transaction.amount > 0) return Colors.green;
    if (transaction.type == TransactionType.giftSent || transaction.type == TransactionType.giftReceived) return Colors.purple;
    if (transaction.type == TransactionType.withdrawal) return Colors.red;
    if (transaction.type == TransactionType.taxDeducted || transaction.type == TransactionType.penalty) return Colors.orange;
    if (transaction.type == TransactionType.freezeAdjustment) return Colors.red.shade400;
    return Colors.blue;
  }

  String _getCurrencyLabel() {
    switch (transaction.currency) {
      case CurrencyType.coins:
        return 'Coins';
      case CurrencyType.diamonds:
        return 'Diamonds';
      case CurrencyType.beans:
        return 'Rewards';
    }
  }

  String _getStatusLabel() {
    switch (transaction.status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }

  Color _getStatusColor() {
    switch (transaction.status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.failed:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}