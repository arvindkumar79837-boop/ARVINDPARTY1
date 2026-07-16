import 'package:flutter/material.dart';

class CoinSellerTransactionsScreen extends StatelessWidget {
  const CoinSellerTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white.withValues(alpha: 0.05),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                index.isEven ? Icons.arrow_downward : Icons.arrow_upward,
                color: index.isEven ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
              ),
              title: Text(
                index.isEven ? 'Purchase' : 'Withdrawal',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Transaction #${index + 1}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              trailing: Text(
                '${index.isEven ? '+' : '-'} ${(index + 1) * 100}',
                style: TextStyle(
                  color: index.isEven ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
