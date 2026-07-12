// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/routes/features/wallet_routes.dart
// ARVIND PARTY - WALLET ROUTES
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

import '../../features/wallet/presentation/bindings/wallet_binding.dart';
import '../../features/wallet/presentation/views/agency_wallet_screen.dart';
import '../../features/wallet/presentation/views/coin_seller_screen.dart';
import '../../features/wallet/presentation/views/coin_wallet_screen.dart';
import '../../features/wallet/presentation/views/diamond_wallet_screen.dart';
import '../../features/wallet/presentation/views/family_wallet_screen.dart';
import '../../features/wallet/presentation/views/recharge_screen.dart';
import '../../features/wallet/presentation/views/transaction_screen.dart';
import '../../features/wallet/presentation/views/treasury_screen.dart';
import '../../features/wallet/presentation/views/wallet_hub_screen.dart';
import '../../features/wallet/presentation/views/withdrawal_management_view.dart';
import '../../features/wallet/presentation/views/withdrawal_screen.dart';

import '../app_routes.dart';

List<GetPage> get walletRoutes => [
  GetPage(name: AppRoutes.walletHub, page: () => const WalletHubScreen(), binding: WalletBinding()),
  GetPage(name: AppRoutes.withdrawal, page: () => const WithdrawalScreen(), binding: WalletBinding()),
  GetPage(name: AppRoutes.withdrawalManagement, page: () => const WithdrawalManagementView(), binding: WalletBinding()),
  GetPage(name: AppRoutes.recharge, page: () => const RechargeScreen(), binding: WalletBinding()),
  GetPage(name: AppRoutes.diamondWallet, page: () => const DiamondWalletScreen(), binding: WalletBinding()),
  GetPage(name: AppRoutes.coinWallet, page: () => const CoinWalletScreen(), binding: WalletBinding()),
  GetPage(name: AppRoutes.familyWallet, page: () => const FamilyWalletScreen(), binding: WalletBinding()),
  GetPage(name: AppRoutes.agencyWallet, page: () => const AgencyWalletScreen(), binding: WalletBinding()),
  GetPage(name: AppRoutes.treasury, page: () => const TreasuryScreen(), binding: WalletBinding()),
  GetPage(name: AppRoutes.transactions, page: () => const TransactionScreen(), binding: WalletBinding()),
  GetPage(name: AppRoutes.coinSeller, page: () => const CoinSellerScreen(), binding: WalletBinding()),
];
