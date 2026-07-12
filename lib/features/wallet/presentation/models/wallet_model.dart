import 'package:flutter/foundation.dart';

enum WalletType { coin, diamond, family, agency }
enum TransactionType { recharge, giftSent, giftReceived, withdrawal, exchangeIn, exchangeOut, reward, bonus, adminAdjust, refund, familyTaskReward, familyContribution, agencyCommission, agencyHostEarning, agencyWithdrawal, dailyTaskReward, loginStreakReward, eventReward, treasureHuntReward, luckyDrawReward, tournamentReward, penalty, taxDeducted, freezeAdjustment, unfreezeAdjustment }
enum TransactionStatus { pending, completed, failed }
enum CurrencyType { coins, diamonds, beans }

class WalletBalance {
  final int coins;
  final int diamonds;
  final int beans;
  const WalletBalance({required this.coins, required this.diamonds, required this.beans});
  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
    coins: json['coins'] ?? 0,
    diamonds: json['diamonds'] ?? 0,
    beans: json['beans'] ?? 0,
  );
  WalletBalance copyWith({int? coins, int? diamonds, int? beans}) {
    return WalletBalance(
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
      beans: beans ?? this.beans,
    );
  }
}

class FamilyWalletData {
  final int coins;
  final int diamonds;
  final int taskCoinsEarned;
  final int rewardCoins;
  final int weeklyEarned;
  final int monthlyEarned;
  final bool isFrozen;
  const FamilyWalletData({
    required this.coins,
    required this.diamonds,
    this.taskCoinsEarned = 0,
    this.rewardCoins = 0,
    this.weeklyEarned = 0,
    this.monthlyEarned = 0,
    this.isFrozen = false,
  });
  factory FamilyWalletData.fromJson(Map<String, dynamic> json) => FamilyWalletData(
    coins: json['totalCoins'] ?? 0,
    diamonds: json['totalDiamonds'] ?? 0,
    taskCoinsEarned: json['taskCoinsEarned'] ?? 0,
    rewardCoins: json['rewardCoins'] ?? 0,
    weeklyEarned: json['weeklyEarned'] ?? 0,
    monthlyEarned: json['monthlyEarned'] ?? 0,
    isFrozen: json['isFrozen'] ?? false,
  );
}

class AgencyWalletData {
  final int balance;
  final int pendingWithdrawal;
  final int totalEarnings;
  final int totalWithdrawn;
  final int estimatedCommission;
  const AgencyWalletData({
    required this.balance,
    this.pendingWithdrawal = 0,
    this.totalEarnings = 0,
    this.totalWithdrawn = 0,
    this.estimatedCommission = 0,
  });
  factory AgencyWalletData.fromJson(Map<String, dynamic> json) => AgencyWalletData(
    balance: json['balance'] ?? 0,
    pendingWithdrawal: json['pendingWithdrawal'] ?? 0,
    totalEarnings: json['totalEarnings'] ?? 0,
    totalWithdrawn: json['totalWithdrawn'] ?? 0,
    estimatedCommission: json['estimatedCommission'] ?? 0,
  );
}

class TodayIncome {
  final int total;
  final int expense;
  final int netChange;
  final int taxDeducted;
  const TodayIncome({this.total = 0, this.expense = 0, this.netChange = 0, this.taxDeducted = 0});
  factory TodayIncome.fromJson(Map<String, dynamic> json) => TodayIncome(
    total: json['total'] ?? 0,
    expense: json['expense'] ?? 0,
    netChange: json['netChange'] ?? 0,
    taxDeducted: json['taxDeducted'] ?? 0,
  );
}

class WalletConfigData {
  final int exchangeRate;
  final int coinPackageRate;
  final int minWithdrawal;
  final int taxPercentage;
  const WalletConfigData({this.exchangeRate = 100, this.coinPackageRate = 10, this.minWithdrawal = 500, this.taxPercentage = 5});
  factory WalletConfigData.fromJson(Map<String, dynamic> json) => WalletConfigData(
    exchangeRate: json['exchangeRate'] ?? 100,
    coinPackageRate: json['coinPackageRate'] ?? 10,
    minWithdrawal: json['minWithdrawal'] ?? 500,
    taxPercentage: json['taxPercentage'] ?? 5,
  );
}

class RechargePackage {
  final String id;
  final String name;
  final double price;
  final int coins;
  final int diamonds;
  final int beans;
  final bool isPopular;
  const RechargePackage({required this.id, required this.name, required this.price, required this.coins, required this.diamonds, required this.beans, this.isPopular = false});
  factory RechargePackage.fromJson(Map<String, dynamic> json) => RechargePackage(
    id: json['id'],
    name: json['name'],
    price: (json['price'] ?? 0).toDouble(),
    coins: json['coins'] ?? 0,
    diamonds: json['diamonds'] ?? 0,
    beans: json['beans'] ?? 0,
    isPopular: json['isPopular'] ?? false,
  );
}

class WithdrawMethod {
  final String id;
  final String name;
  final String iconUrl;
  final double minAmount;
  final double maxAmount;
  final double feePercentage;
  const WithdrawMethod({required this.id, required this.name, required this.iconUrl, required this.minAmount, required this.maxAmount, required this.feePercentage});
  factory WithdrawMethod.fromJson(Map<String, dynamic> json) => WithdrawMethod(
    id: json['id'],
    name: json['name'],
    iconUrl: json['iconUrl'] ?? 'https://picsum.photos/seed/withdraw/50',
    minAmount: (json['minAmount'] ?? 0).toDouble(),
    maxAmount: (json['maxAmount'] ?? 0).toDouble(),
    feePercentage: (json['feePercentage'] ?? 0.0).toDouble(),
  );
}

class TransactionModel {
  final String id;
  final String transactionId;
  final TransactionType type;
  final WalletType walletType;
  final CurrencyType currency;
  final int amount;
  final int balanceBefore;
  final int balanceAfter;
  final String? description;
  final TransactionStatus status;
  final String? paymentMethodId;
  final int taxAmount;
  final int taxPercentage;
  final String? referenceId;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.transactionId,
    required this.type,
    required this.walletType,
    required this.currency,
    required this.amount,
    this.balanceBefore = 0,
    this.balanceAfter = 0,
    this.description,
    required this.status,
    this.paymentMethodId,
    this.taxAmount = 0,
    this.taxPercentage = 0,
    this.referenceId,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final String typeStr = json['type'] ?? 'recharge';
    TransactionType txType;
    try {
      txType = TransactionType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => TransactionType.recharge,
      );
    } catch (e) {
      txType = TransactionType.recharge;
      debugPrint('Transaction type parse error: $e');
    }

    final String walletStr = json['walletType'] ?? 'coin';
    WalletType wType;
    try {
      wType = WalletType.values.firstWhere((e) => e.name == walletStr);
    } catch (e) {
      wType = WalletType.coin;
      debugPrint('Wallet type parse error: $e');
    }

    return TransactionModel(
      id: json['_id'] ?? json['id'] ?? '',
      transactionId: json['transactionId'] ?? '',
      type: txType,
      walletType: wType,
      currency: CurrencyType.values.firstWhere(
        (e) => e.name == (json['currency'] ?? 'coins'),
        orElse: () => CurrencyType.coins,
      ),
      amount: json['amount'] ?? 0,
      balanceBefore: json['balanceBefore'] ?? 0,
      balanceAfter: json['balanceAfter'] ?? 0,
      description: json['description'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'completed'),
        orElse: () => TransactionStatus.completed,
      ),
      paymentMethodId: json['paymentMethodId'],
      taxAmount: json['taxAmount'] ?? 0,
      taxPercentage: json['taxPercentage'] ?? 0,
      referenceId: json['referenceId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class MemberContribution {
  final String userId;
  final String uid;
  final int coinsContributed;
  final int diamondsContributed;
  final int tasksCompleted;
  final DateTime? lastContributedAt;
  final Map<String, dynamic>? userDetails;

  const MemberContribution({
    required this.userId,
    this.uid = '',
    this.coinsContributed = 0,
    this.diamondsContributed = 0,
    this.tasksCompleted = 0,
    this.lastContributedAt,
    this.userDetails,
  });

  factory MemberContribution.fromJson(Map<String, dynamic> json) => MemberContribution(
    userId: json['userId'] ?? '',
    uid: json['uid'] ?? '',
    coinsContributed: json['coinsContributed'] ?? 0,
    diamondsContributed: json['diamondsContributed'] ?? 0,
    tasksCompleted: json['tasksCompleted'] ?? 0,
    lastContributedAt: json['lastContributedAt'] != null ? DateTime.tryParse(json['lastContributedAt']) : null,
    userDetails: json['userDetails'] as Map<String, dynamic>?,
  );
}

class FamilyData {
  final String name;
  final String badge;
  final int level;
  final int xp;
  final int memberCount;
  const FamilyData({required this.name, this.badge = '', this.level = 1, this.xp = 0, this.memberCount = 0});
  factory FamilyData.fromJson(Map<String, dynamic> json) => FamilyData(
    name: json['name'] ?? '',
    badge: json['badge'] ?? '',
    level: json['level'] ?? 1,
    xp: json['xp'] ?? 0,
    memberCount: json['memberCount'] ?? 0,
  );
}

class AgencyData {
  final String name;
  final int totalHosts;
  final double commissionRate;
  const AgencyData({required this.name, this.totalHosts = 0, this.commissionRate = 0.1});
  factory AgencyData.fromJson(Map<String, dynamic> json) => AgencyData(
    name: json['name'] ?? '',
    totalHosts: json['totalHosts'] ?? 0,
    commissionRate: (json['commissionRate'] ?? 0.1).toDouble(),
  );
}

class HostSummary {
  final String uid;
  final String name;
  final String avatar;
  final int diamonds;
  final int coins;
  final int estimatedAgencyEarning;
  const HostSummary({
    required this.uid,
    this.name = '',
    this.avatar = '',
    this.diamonds = 0,
    this.coins = 0,
    this.estimatedAgencyEarning = 0,
  });
  factory HostSummary.fromJson(Map<String, dynamic> json) => HostSummary(
    uid: json['uid'] ?? '',
    name: json['name'] ?? '',
    avatar: json['avatar'] ?? '',
    diamonds: json['diamonds'] ?? 0,
    coins: json['coins'] ?? 0,
    estimatedAgencyEarning: json['estimatedAgencyEarning'] ?? 0,
  );
}

class ContributionSummary {
  final int coinsContributed;
  final int diamondsContributed;
  final int tasksCompleted;
  const ContributionSummary({this.coinsContributed = 0, this.diamondsContributed = 0, this.tasksCompleted = 0});
  factory ContributionSummary.fromJson(Map<String, dynamic> json) => ContributionSummary(
    coinsContributed: json['coinsContributed'] ?? 0,
    diamondsContributed: json['diamondsContributed'] ?? 0,
    tasksCompleted: json['tasksCompleted'] ?? 0,
  );
}