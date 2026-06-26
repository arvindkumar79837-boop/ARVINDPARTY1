enum DealerLevel { silver, gold, diamond }

enum RefundStatus { pending, approved, rejected, refunded }

enum RefundPriority { low, normal, high, urgent }

class DealerWalletModel {
  final String uid;
  final String username;
  final int balance;
  final int totalReceived;
  final int totalTransferred;
  final int totalRefunded;
  final DealerLevel level;
  final int commissionPercent;
  final double bonusPercent;
  final int totalTransactions;
  final int totalCustomersServed;
  final int dailyTransferCount;
  final DateTime? lastTransferDate;
  final bool isActive;
  final bool isVerified;
  final double maxTransferPerTransaction;
  final double dailyTransferLimit;
  final double currentDailyTransfer;
  final int suspiciousActivityCount;
  final bool isFlagged;

  const DealerWalletModel({
    required this.uid,
    required this.username,
    required this.balance,
    required this.totalReceived,
    required this.totalTransferred,
    required this.totalRefunded,
    required this.level,
    required this.commissionPercent,
    required this.bonusPercent,
    required this.totalTransactions,
    required this.totalCustomersServed,
    required this.dailyTransferCount,
    this.lastTransferDate,
    required this.isActive,
    required this.isVerified,
    required this.maxTransferPerTransaction,
    required this.dailyTransferLimit,
    required this.currentDailyTransfer,
    required this.suspiciousActivityCount,
    required this.isFlagged,
  });

  factory DealerWalletModel.fromJson(Map<String, dynamic> json) {
    final levelStr = (json['level'] ?? 'silver').toString().toLowerCase();
    DealerLevel level = DealerLevel.silver;
    if (levelStr == 'gold') level = DealerLevel.gold;
    if (levelStr == 'diamond') level = DealerLevel.diamond;

    return DealerWalletModel(
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      balance: json['balance'] ?? 0,
      totalReceived: json['totalReceived'] ?? 0,
      totalTransferred: json['totalTransferred'] ?? 0,
      totalRefunded: json['totalRefunded'] ?? 0,
      level: level,
      commissionPercent: json['commissionPercent'] ?? 0,
      bonusPercent: (json['bonusPercent'] ?? 0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      totalCustomersServed: json['totalCustomersServed'] ?? 0,
      dailyTransferCount: json['dailyTransferCount'] ?? 0,
      lastTransferDate: json['lastTransferDate'] != null ? DateTime.tryParse(json['lastTransferDate']) : null,
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'] ?? false,
      maxTransferPerTransaction: (json['maxTransferPerTransaction'] ?? 50000).toDouble(),
      dailyTransferLimit: (json['dailyTransferLimit'] ?? 500000).toDouble(),
      currentDailyTransfer: (json['currentDailyTransfer'] ?? 0).toDouble(),
      suspiciousActivityCount: json['suspiciousActivityCount'] ?? 0,
      isFlagged: json['isFlagged'] ?? false,
    );
  }

  double get remainingDailyLimit => dailyTransferLimit - currentDailyTransfer;
}

class DealerTransferResponse {
  final String transactionHash;
  final int amountTransferred;
  final String targetUid;
  final String? targetUsername;
  final int dealerNewBalance;
  final int userNewBalance;
  final String timestamp;

  const DealerTransferResponse({
    required this.transactionHash,
    required this.amountTransferred,
    required this.targetUid,
    this.targetUsername,
    required this.dealerNewBalance,
    required this.userNewBalance,
    required this.timestamp,
  });

  factory DealerTransferResponse.fromJson(Map<String, dynamic> json) {
    return DealerTransferResponse(
      transactionHash: json['transactionHash'] ?? '',
      amountTransferred: json['amountTransferred'] ?? 0,
      targetUid: json['targetUid'] ?? '',
      targetUsername: json['targetUsername'],
      dealerNewBalance: json['dealerNewBalance'] ?? 0,
      userNewBalance: json['userNewBalance'] ?? 0,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class DealerRefundModel {
  final String refundId;
  final String dealerUid;
  final String dealerUsername;
  final String targetUid;
  final String transactionHash;
  final int coinsToRefund;
  final String reason;
  final String? errorDescription;
  final RefundStatus status;
  final DateTime createdAt;

  const DealerRefundModel({
    required this.refundId,
    required this.dealerUid,
    required this.dealerUsername,
    required this.targetUid,
    required this.transactionHash,
    required this.coinsToRefund,
    required this.reason,
    this.errorDescription,
    required this.status,
    required this.createdAt,
  });

  factory DealerRefundModel.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? 'pending').toLowerCase();
    RefundStatus status = RefundStatus.pending;
    if (statusStr == 'approved') status = RefundStatus.approved;
    if (statusStr == 'rejected') status = RefundStatus.rejected;
    if (statusStr == 'refunded') status = RefundStatus.refunded;

    return DealerRefundModel(
      refundId: json['refundId'] ?? json['_id'] ?? '',
      dealerUid: json['dealerUid'] ?? '',
      dealerUsername: json['dealerUsername'] ?? '',
      targetUid: json['targetUid'] ?? '',
      transactionHash: json['transactionHash'] ?? '',
      coinsToRefund: json['coinsToRefund'] ?? 0,
      reason: json['reason'] ?? '',
      errorDescription: json['errorDescription'],
      status: status,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class DealerStats {
  final DealerInfo dealerInfo;
  final WalletSummary wallet;
  final DayStats today;
  final MonthStats month;
  final RefundSummary refunds;
  final PerformanceStats performance;

  const DealerStats({
    required this.dealerInfo,
    required this.wallet,
    required this.today,
    required this.month,
    required this.refunds,
    required this.performance,
  });

  factory DealerStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return DealerStats(
      dealerInfo: DealerInfo.fromJson(data['dealerInfo'] ?? {}),
      wallet: WalletSummary.fromJson(data['wallet'] ?? {}),
      today: DayStats.fromJson(data['today'] ?? {}),
      month: MonthStats.fromJson(data['month'] ?? {}),
      refunds: RefundSummary.fromJson(data['refunds'] ?? {}),
      performance: PerformanceStats.fromJson(data['performance'] ?? {}),
    );
  }
}

class DealerInfo {
  final String uid;
  final String username;
  final DealerLevel level;
  final int commissionPercent;
  final double bonusPercent;
  final bool isVerified;
  final DateTime createdAt;

  const DealerInfo({
    required this.uid,
    required this.username,
    required this.level,
    required this.commissionPercent,
    required this.bonusPercent,
    required this.isVerified,
    required this.createdAt,
  });

  factory DealerInfo.fromJson(Map<String, dynamic> json) {
    final levelStr = (json['level'] ?? 'silver').toString().toLowerCase();
    DealerLevel level = DealerLevel.silver;
    if (levelStr == 'gold') level = DealerLevel.gold;
    if (levelStr == 'diamond') level = DealerLevel.diamond;

    return DealerInfo(
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      level: level,
      commissionPercent: json['commissionPercent'] ?? 0,
      bonusPercent: (json['bonusPercent'] ?? 0).toDouble(),
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class WalletSummary {
  final int currentBalance;
  final int totalReceived;
  final int totalTransferred;
  final int totalRefunded;
  final int totalTransactions;
  final int totalCustomersServed;

  const WalletSummary({
    required this.currentBalance,
    required this.totalReceived,
    required this.totalTransferred,
    required this.totalRefunded,
    required this.totalTransactions,
    required this.totalCustomersServed,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      currentBalance: json['currentBalance'] ?? 0,
      totalReceived: json['totalReceived'] ?? 0,
      totalTransferred: json['totalTransferred'] ?? 0,
      totalRefunded: json['totalRefunded'] ?? 0,
      totalTransactions: json['totalTransactions'] ?? 0,
      totalCustomersServed: json['totalCustomersServed'] ?? 0,
    );
  }
}

class DayStats {
  final int transfersCount;
  final double volume;
  final double remainingLimit;

  const DayStats({
    required this.transfersCount,
    required this.volume,
    required this.remainingLimit,
  });

  factory DayStats.fromJson(Map<String, dynamic> json) {
    return DayStats(
      transfersCount: json['transfersCount'] ?? 0,
      volume: (json['volume'] ?? 0).toDouble(),
      remainingLimit: (json['remainingLimit'] ?? 0).toDouble(),
    );
  }
}

class MonthStats {
  final double volume;

  const MonthStats({required this.volume});

  factory MonthStats.fromJson(Map<String, dynamic> json) {
    return MonthStats(volume: (json['volume'] ?? 0).toDouble());
  }
}

class RefundSummary {
  final int pending;

  const RefundSummary({required this.pending});

  factory RefundSummary.fromJson(Map<String, dynamic> json) {
    return RefundSummary(pending: json['pending'] ?? 0);
  }
}

class PerformanceStats {
  final double successRate;
  final int averageTransactionSize;

  const PerformanceStats({
    required this.successRate,
    required this.averageTransactionSize,
  });

  factory PerformanceStats.fromJson(Map<String, dynamic> json) {
    return PerformanceStats(
      successRate: (json['successRate'] ?? 100).toDouble(),
      averageTransactionSize: json['averageTransactionSize'] ?? 0,
    );
  }
}

class DealerListResponse {
  final List<DealerWalletModel> dealers;
  final DealerListStats stats;

  const DealerListResponse({
    required this.dealers,
    required this.stats,
  });

  factory DealerListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return DealerListResponse(
      dealers: (data['dealers'] as List<dynamic>? ?? [])
          .map((e) => DealerWalletModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: DealerListStats.fromJson(data['stats'] ?? {}),
    );
  }
}

class DealerListStats {
  final int totalDealers;
  final int activeDealers;
  final int flaggedDealers;
  final int verifiedDealers;
  final int totalBalance;

  const DealerListStats({
    required this.totalDealers,
    required this.activeDealers,
    required this.flaggedDealers,
    required this.verifiedDealers,
    required this.totalBalance,
  });

  factory DealerListStats.fromJson(Map<String, dynamic> json) {
    return DealerListStats(
      totalDealers: json['totalDealers'] ?? 0,
      activeDealers: json['activeDealers'] ?? 0,
      flaggedDealers: json['flaggedDealers'] ?? 0,
      verifiedDealers: json['verifiedDealers'] ?? 0,
      totalBalance: json['totalBalance'] ?? 0,
    );
  }
}