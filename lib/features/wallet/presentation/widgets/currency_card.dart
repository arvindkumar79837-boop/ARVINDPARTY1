// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/widgets/currency_card.dart
// ARVIND PARTY - CURRENCY CARD WIDGET
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class CurrencyCard extends StatelessWidget {
  final CurrencyType type;
  final int amount;
  final String? subtitle;
  final VoidCallback? onTap;

  const CurrencyCard({
    super.key,
    required this.type,
    required this.amount,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String label;

    switch (type) {
      case CurrencyType.coins:
        icon = Icons.monetization_on;
        color = Colors.orange;
        label = 'Coins';
        break;
      case CurrencyType.diamonds:
        icon = Icons.diamond;
        color = Colors.cyan;
        label = 'Diamonds';
        break;
      case CurrencyType.beans:
        icon = Icons.eco;
        color = Colors.green;
        label = 'Rewards';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
              ],
              const SizedBox(height: 4),
              Text(
                _formatAmount(amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toString();
  }
}