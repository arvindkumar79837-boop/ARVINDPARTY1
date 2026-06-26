// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/widgets/recharge_package_item.dart
// ARVIND PARTY - RECHARGE PACKAGE ITEM WIDGET
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class RechargePackageItem extends StatelessWidget {
  final RechargePackage package;
  final bool isSelected;
  final VoidCallback onTap;

  const RechargePackageItem({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? Colors.blue.withValues(alpha: 0.08) : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Text(
                    '${package.coins > 0 ? package.coins : package.diamonds > 0 ? package.diamonds : package.beans} ${package.coins > 0 ? "Coins" : package.diamonds > 0 ? "Diamonds" : "Rewards"}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              '₹${package.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}