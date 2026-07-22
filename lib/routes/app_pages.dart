// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/routes/app_pages.dart
// ARVIND PARTY - MASTER ROUTE TABLE
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

import '../core/middleware/auth_guard_middleware.dart';
import '../features/admin/presentation/bindings/admin_binding.dart';
// Admin
import '../features/admin/presentation/views/admin_dashboard_screen.dart';
import '../features/admin/presentation/views/admin_wallet_management_view.dart';
import '../features/admin/presentation/views/broadcast_screen.dart';
import '../features/admin/presentation/views/staff_management_screen.dart';
import '../features/agency/presentation/bindings/agency_binding.dart';
import '../features/agency/presentation/views/agency_analytics_screen.dart';
import '../features/agency/presentation/views/agency_events_screen.dart';
// Agency
import '../features/agency/presentation/views/agency_home_screen.dart';
import '../features/agency/presentation/views/agency_leaderboard_screen.dart';
import '../features/agency/presentation/views/agency_members_screen.dart';
import '../features/agency/presentation/views/agency_ranking_screen.dart';
import '../features/agency/presentation/views/agency_salary_screen.dart';
import '../features/agency/presentation/views/create_agency_screen.dart';
import '../features/analytics/presentation/bindings/analytics_binding.dart';
// Analytics
import '../features/analytics/presentation/views/analytics_dashboard_screen.dart';
import '../features/auth/presentation/bindings/auth_binding.dart';
import '../features/auth/presentation/views/account_security_screen.dart';
import '../features/auth/presentation/views/device_binding_screen.dart';
import '../features/auth/presentation/views/edit_profile_screen.dart' as auth_edit;
import '../features/auth/presentation/views/email_login_screen.dart';
// Auth
import '../features/auth/presentation/views/login_screen.dart';
import '../features/auth/presentation/views/mobile_security_screen.dart';
import '../features/auth/presentation/views/multi_device_control_screen.dart';
import '../features/auth/presentation/views/otp_screen.dart';
import '../features/auth/presentation/views/password_reset_screen.dart';
import '../features/auth/presentation/views/firebase_phone_auth_screen.dart';
import '../features/auth/presentation/views/session_management_screen.dart';
import '../features/auth/presentation/views/signup_screen.dart';
import '../features/auth/presentation/views/social_login_screen.dart';
import '../features/block/bindings/block_binding.dart';
// Block
import '../features/block/views/blacklist_screen.dart';
import '../features/chat/presentation/bindings/chat_binding.dart';
import '../features/chat/presentation/views/private_chat_screen.dart';
// Chat
import '../features/chat/presentation/views/room_chat_screen.dart';
import '../features/cp/presentation/bindings/coin_seller_binding.dart';
// Coin Seller
import '../features/cp/presentation/views/coin_seller_home_screen.dart' as cp_home;
import '../features/cp/presentation/views/coin_seller_profile_screen.dart' as cp_profile;
import '../features/cp/presentation/views/coin_seller_ranking_screen.dart' as cp_ranking;
import '../features/cp/presentation/views/coin_seller_transactions_screen.dart';
import '../features/cp/presentation/views/recharge_history_screen.dart' as cp_recharge;
import '../features/cp/presentation/views/settlement_history_screen.dart' as cp_settlement;
import '../features/dealer/presentation/bindings/dealer_binding.dart';
// Dealer
import '../features/dealer/presentation/views/dealer_wallet_screen.dart';
import '../features/events/presentation/bindings/events_binding.dart';
// Events
import '../features/events/presentation/views/events_screen.dart';
import '../features/family/presentation/bindings/family_binding.dart';
import '../features/family/presentation/views/create_family_screen.dart';
import '../features/family/presentation/views/family_chat_screen.dart';
import '../features/family/presentation/views/family_members_screen.dart';
import '../features/family/presentation/views/family_ranking_screen.dart';
// Family
import '../features/family/presentation/views/family_screen.dart';
import '../features/family/presentation/views/family_tasks_screen.dart';
import '../features/family/presentation/views/family_wallet_screen.dart';
import '../features/family/presentation/views/family_wars_screen.dart';
import '../features/friend/presentation/bindings/friend_binding.dart';
// Friend
import '../features/friend/presentation/views/friend_screen.dart';
import '../features/friend/presentation/views/friend_search_screen.dart';
import '../features/games/presentation/bindings/games_binding.dart';
import '../features/games/presentation/views/game_history_screen.dart';
import '../features/games/presentation/views/game_leaderboard_screen.dart' as games_leaderboard;
// Games
import '../features/games/presentation/views/game_screen.dart';
import '../features/games/presentation/views/scratch_card_screen.dart';
import '../features/gift/presentation/bindings/gift_binding.dart';
// Gift
import '../features/gift/presentation/views/gift_history_screen.dart';
import '../features/gift/presentation/views/gift_ranking_screen.dart';
import '../features/gift/presentation/views/gift_screen.dart';
import '../features/home/presentation/bindings/home_binding.dart';
// Home
import '../features/home/presentation/views/home_screen.dart';
import '../features/inventory/presentation/bindings/inventory_binding.dart';
// Inventory
import '../features/inventory/presentation/views/inventory_screen.dart';
import '../features/level/presentation/bindings/level_binding.dart';
// Level
import '../features/level/presentation/views/level_screen.dart';
import '../features/lucky_draw/presentation/bindings/lucky_draw_binding.dart';
// Lucky Draw
import '../features/lucky_draw/presentation/views/lucky_draw_screen.dart';
import '../features/media/presentation/bindings/media_binding.dart';
// Media
import '../features/media/presentation/views/media_player_screen.dart';
import '../features/media/presentation/views/playlist_screen.dart';
import '../features/media/presentation/views/sound_effects_panel.dart';
import '../features/media/presentation/views/youtube_screen.dart';
import '../features/notifications/presentation/bindings/notifications_binding.dart';
// Notification (merged - using the notification feature)
import '../features/notifications/presentation/views/notification_screen.dart';
import '../features/profile/presentation/bindings/profile_binding.dart';
import '../features/profile/presentation/views/complete_profile_screen.dart';
import '../features/profile/presentation/views/gallery_screen.dart';
import '../features/profile/presentation/views/mission_screen.dart' as profile_mission;
// Profile
import '../features/profile/presentation/views/profile_screen.dart';
import '../features/profile/presentation/views/transaction_history_screen.dart';
import '../features/profile/presentation/views/user_profile_view.dart';
import '../features/profile/presentation/views/visitor_history_screen.dart';
import '../features/ranking/presentation/bindings/ranking_binding.dart';
// Ranking
import '../features/ranking/presentation/views/game_leaderboard_screen.dart';
import '../features/room/presentation/bindings/room_binding.dart';
import '../features/room/presentation/views/create_room_screen.dart';
// Room Admin
import '../features/room/presentation/views/host_controls_screen.dart';
import '../features/room/presentation/views/live_room_screen.dart';
import '../features/room/presentation/views/moderator_controls_screen.dart';
import '../features/room/presentation/views/room_analytics_screen.dart';
import '../features/room/presentation/views/room_background_screen.dart';
import '../features/room/presentation/views/room_detail_screen.dart';
// Room
import '../features/room/presentation/views/room_list_screen.dart';
import '../features/room/presentation/views/room_lock_screen.dart';
import '../features/room_features/presentation/bindings/room_features_binding.dart';
import '../features/room_features/presentation/views/room_features_screen.dart';
import '../features/search/presentation/bindings/search_binding.dart';
// Search
import '../features/search/presentation/views/search_screen.dart' as search_screen;
import '../features/settings/presentation/bindings/settings_binding.dart';
import '../features/settings/presentation/views/privacy_screen.dart';
// Settings
import '../features/settings/presentation/views/settings_screen.dart';
import '../features/settings/presentation/views/social_links_screen.dart';
import '../features/shop/presentation/bindings/shop_binding.dart';
// Shop
import '../features/shop/presentation/views/shop_screen.dart';
import '../features/splash/presentation/bindings/splash_binding.dart';
// Splash
import '../features/splash/presentation/views/splash_screen.dart';
import '../features/support/presentation/bindings/support_binding.dart';
// Support
import '../features/support/presentation/views/support_screen.dart';
import '../features/vip_system/bindings/vip_system_binding.dart';
import '../features/vip_system/views/vip_cosmetics_view.dart';
// VIP System NEW (VIP 1-15, SVIP, Premium, Cosmetics, Missions)
import '../features/vip_system/views/vip_dashboard_view.dart';
import '../features/vip_system/views/vip_missions_view.dart';
import '../features/vip_system/views/vip_shop_view.dart';
import '../features/premium/presentation/bindings/premium_binding.dart';
import '../features/premium/presentation/views/premium_screen.dart';
import '../features/blind_date/presentation/bindings/blind_date_binding.dart';
import '../features/blind_date/presentation/views/blind_date_screen.dart';
import '../features/singing_room/presentation/bindings/singing_room_binding.dart';
import '../features/singing_room/presentation/views/singing_room_screen.dart';
import '../features/power_matrix/presentation/bindings/power_matrix_binding.dart';
import '../features/power_matrix/presentation/views/power_matrix_view.dart';
import '../features/youtube/presentation/bindings/youtube_binding.dart';
import '../features/youtube/presentation/views/youtube_room_screen.dart';
import '../features/wallet/presentation/bindings/wallet_binding.dart';
import '../features/wallet/presentation/views/coin_wallet_screen.dart';
import '../features/wallet/presentation/views/diamond_wallet_screen.dart';
import '../features/wallet/presentation/views/payment_success_screen.dart';
import '../features/wallet/presentation/views/reward_wallet_screen.dart';
import '../features/wallet/presentation/views/treasury_panel_screen.dart';
// User Center
import '../features/wallet/presentation/views/user_center_screen.dart';
// Wallet
import '../features/wallet/presentation/views/wallet_hub_screen.dart';
import '../features/wallet/presentation/views/withdrawal_management_view.dart';
import '../features/wallet/presentation/views/withdrawal_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    // ─── SPLASH ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),

    // ─── AUTH ─────────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.phoneAuth,
      page: () => const FirebasePhoneAuthScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.emailLogin,
      page: () => const EmailLoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.googleLogin,
      page: () => const SocialLoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.facebookLogin,
      page: () => const SocialLoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.appleLogin,
      page: () => const SocialLoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.guestLogin,
      page: () => const SocialLoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.passwordReset,
      page: () => const PasswordResetScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.deviceBinding,
      page: () => const DeviceBindingScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.multiDeviceControl,
      page: () => const MultiDeviceControlScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.sessionManagement,
      page: () => const SessionManagementScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.accountSecurity,
      page: () => const AccountSecurityScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.securityCenter,
      page: () => const MobileSecurityScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.completeProfile,
      page: () => CompleteProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const auth_edit.EditProfileScreen(),
      binding: AuthBinding(),
    ),

    // ─── HOME ─────────────────────────────────────────────
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const search_screen.GlobalSearchScreen(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: AppRoutes.vip,
      page: () => const VipDashboardView(),
      binding: VipSystemBinding(),
    ),

    // ─── VIP SYSTEM NEW ──────────────────────────────────
    GetPage(
      name: AppRoutes.vipDashboard,
      page: () => const VipDashboardView(),
      binding: VipSystemBinding(),
    ),
    GetPage(
      name: AppRoutes.vipShop,
      page: () => const VipShopView(),
      binding: VipSystemBinding(),
    ),
    GetPage(
      name: AppRoutes.vipMissions,
      page: () => const VipMissionsView(),
      binding: VipSystemBinding(),
    ),
    GetPage(
      name: AppRoutes.vipCosmetics,
      page: () => const VipCosmeticsView(),
      binding: VipSystemBinding(),
    ),
    GetPage(
      name: AppRoutes.premium,
      page: () => const PremiumScreen(),
      binding: PremiumBinding(),
    ),
    GetPage(
      name: AppRoutes.blindDate,
      page: () => const BlindDateScreen(),
      binding: BlindDateBinding(),
    ),
    GetPage(
      name: AppRoutes.singingRoom,
      page: () => const SingingRoomScreen(),
      binding: SingingRoomBinding(),
    ),
    GetPage(
      name: AppRoutes.vipLeaderboard,
      page: () => const VipDashboardView(),
      binding: VipSystemBinding(),
    ),

    // ─── PROFILE ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.userProfile,
      page: () => const UserProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.dailyMissions,
      page: () => const profile_mission.MissionScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.walletHistory,
      page: () => const TransactionHistoryScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.gallery,
      page: () => const GalleryScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.visitorHistory,
      page: () => const VisitorHistoryScreen(),
      binding: ProfileBinding(),
    ),

    // ─── WALLET ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletHubScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.coinWallet,
      page: () => const CoinWalletScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.diamondWallet,
      page: () => const DiamondWalletScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.rewardWallet,
      page: () => const RewardWalletScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.treasuryPanel,
      page: () => const TreasuryPanelScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.withdrawal,
      page: () => const WithdrawalScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.withdrawalManagement,
      page: () => const WithdrawalManagementView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.shop,
      page: () => const ShopScreen(),
      binding: ShopBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentSuccess,
      page: () => const PaymentSuccessScreen(),
      binding: WalletBinding(),
    ),

    // ─── LUCKY DRAW ──────────────────────────────────────
    GetPage(
      name: AppRoutes.luckySpin,
      page: () => const LuckyDrawScreen(),
      binding: LuckyDrawBinding(),
    ),
    GetPage(
      name: AppRoutes.gameCenter,
      page: () => const games_leaderboard.GameLeaderboardScreen(),
      binding: RankingBinding(),
    ),
    GetPage(
      name: AppRoutes.games,
      page: () => const GameScreen(),
      binding: GamesBinding(),
    ),
    GetPage(
      name: AppRoutes.luckyNumber,
      page: () => const ScratchCardScreen(),
      binding: GamesBinding(),
    ),
    GetPage(
      name: AppRoutes.diceGame,
      page: () => const ScratchCardScreen(),
      binding: GamesBinding(),
    ),
    GetPage(
      name: AppRoutes.miniCompetitions,
      page: () => const GameLeaderboardScreen(),
      binding: GamesBinding(),
    ),
    GetPage(
      name: AppRoutes.drawHistory,
      page: () => const GameHistoryScreen(),
      binding: GamesBinding(),
    ),

    // ─── EVENTS ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.eventListing,
      page: () => const EventsScreen(),
      binding: EventsBinding(),
    ),

    // ─── NOTIFICATIONS ──────────────────────────────────
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationScreen(),
      binding: NotificationsBinding(),
    ),

    // ─── USER CENTER ─────────────────────────────────────
    GetPage(
      name: AppRoutes.userCenter,
      page: () => const UserCenterScreen(),
      binding: WalletBinding(),
    ),

    // ─── ROOM ──────────────────────────────────────────────
    GetPage(
      name: AppRoutes.roomList,
      page: () => const RoomListScreen(),
      binding: RoomBinding(),
    ),
    GetPage(
      name: AppRoutes.createRoom,
      page: () => CreateRoomScreen(),
      binding: RoomBinding(),
    ),
    GetPage(
      name: AppRoutes.roomDetail,
      page: () => const RoomDetailScreen(),
      binding: RoomBinding(),
    ),
    GetPage(
      name: AppRoutes.liveRoom,
      page: () => const LiveRoomScreen(),
      binding: RoomBinding(roomId: 'liveRoom'),
    ),
    GetPage(
      name: AppRoutes.voiceRoom,
      page: () => const RoomListScreen(),
      binding: RoomBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.hostControls,
      page: () => const HostControlsScreen(roomId: 'host'),
      binding: RoomBinding(roomId: 'host'),
    ),
    GetPage(
      name: AppRoutes.coHostControls,
      page: () => const HostControlsScreen(roomId: 'coHost'),
      binding: RoomBinding(roomId: 'coHost'),
    ),
    GetPage(
      name: AppRoutes.moderatorControls,
      page: () => const ModeratorControlsScreen(),
      binding: RoomBinding(roomId: 'moderator'),
    ),
    GetPage(
      name: AppRoutes.roomLock,
      page: () => const RoomLockScreen(),
      binding: RoomBinding(roomId: 'roomLock'),
    ),
    GetPage(
      name: AppRoutes.roomBackground,
      page: () => const RoomBackgroundScreen(),
      binding: RoomBinding(roomId: 'roomBackground'),
    ),
    GetPage(
      name: AppRoutes.roomAnalytics,
      page: () => const RoomAnalyticsScreen(),
      binding: RoomBinding(roomId: 'roomAnalytics'),
    ),
    GetPage(
      name: AppRoutes.roomFeatures,
      page: () => const RoomFeaturesScreen(
        roomId: '',
        userId: '',
        userName: '',
      ),
      binding: RoomFeaturesBinding(),
    ),
    GetPage(
      name: AppRoutes.giftStatistics,
      page: () => const GiftHistoryScreen(),
      binding: GiftBinding(),
    ),
    GetPage(
      name: AppRoutes.giftLeaderboard,
      page: () => const GiftRankingScreen(),
      binding: GiftBinding(),
    ),
    GetPage(
      name: AppRoutes.giftShop,
      page: () => const GiftScreen(),
      binding: GiftBinding(),
    ),
    GetPage(
      name: AppRoutes.giftRanking,
      page: () => const GiftRankingScreen(),
      binding: GiftBinding(),
    ),
    GetPage(
      name: AppRoutes.charmRanking,
      page: () => const GiftRankingScreen(),
      binding: GiftBinding(),
    ),

    // ─── CHAT ─────────────────────────────────────────────
    GetPage(
      name: AppRoutes.chat,
      page: () => const RoomChatScreen(roomId: 'room1', roomName: 'Chat'),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.privateChat,
      page: () => const PrivateChatScreen(),
      binding: ChatBinding(),
    ),

    // ─── FRIEND ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.friends,
      page: () => const FriendScreen(),
      binding: FriendBinding(),
    ),
    GetPage(
      name: AppRoutes.friendSearch,
      page: () => const FriendSearchScreen(),
      binding: FriendBinding(),
    ),

    // ─── BLOCK ────────────────────────────────────────────
    GetPage(
      name: AppRoutes.blacklist,
      page: () => const BlacklistScreen(),
      binding: BlockBinding(),
    ),
    GetPage(
      name: AppRoutes.blockList,
      page: () => const BlacklistScreen(),
      binding: BlockBinding(),
    ),

    // ─── FAMILY ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.family,
      page: () => const FamilyScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyCreation,
      page: () => const CreateFamilyScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyChat,
      page: () => const FamilyChatScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyMembers,
      page: () => const FamilyMembersScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyTasks,
      page: () => const FamilyTasksScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyRankingPage,
      page: () => const FamilyRankingScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyWars,
      page: () => const FamilyWarsScreen(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyWallet,
      page: () => const FamilyWalletScreen(),
      binding: FamilyBinding(),
    ),

    // ─── COIN SELLER ─────────────────────────────────────
    GetPage(
      name: AppRoutes.coinSeller,
      page: () => const cp_home.CoinSellerHomeScreen(),
      binding: CoinSellerBinding(),
    ),
    GetPage(
      name: AppRoutes.coinSellerProfile,
      page: () => const cp_profile.CoinSellerProfileScreen(),
      binding: CoinSellerBinding(),
    ),
    GetPage(
      name: AppRoutes.coinSellerRanking,
      page: () => const cp_ranking.CoinSellerRankingScreen(),
      binding: CoinSellerBinding(),
    ),
    GetPage(
      name: AppRoutes.rechargeHistory,
      page: () => const cp_recharge.RechargeHistoryScreen(),
      binding: CoinSellerBinding(),
    ),
    GetPage(
      name: AppRoutes.settlementHistory,
      page: () => const cp_settlement.SettlementHistoryScreen(),
      binding: CoinSellerBinding(),
    ),
    GetPage(
      name: AppRoutes.coinSellerTransactions,
      page: () => const CoinSellerTransactionsScreen(),
      binding: CoinSellerBinding(),
    ),
    GetPage(
      name: AppRoutes.dealerWallet,
      page: () => const DealerWalletScreen(),
      binding: DealerBinding(),
    ),

    // ─── AGENCY ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.agency,
      page: () => const AgencyHomeScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.agencyCreation,
      page: () => const CreateAgencyScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.agencyHosts,
      page: () => const AgencyMembersScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.agencyEarnings,
      page: () => const AgencyAnalyticsScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.eventHistory,
      page: () => const AgencyEventsScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.agencyWallet,
      page: () => const AgencySalaryScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.agencyRanking,
      page: () => const AgencyRankingScreen(),
      binding: AgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.agencyLeaderboard,
      page: () => const AgencyLeaderboardScreen(),
      binding: AgencyBinding(),
    ),

    // ─── MEDIA / MUSIC ───────────────────────────────────
    GetPage(
      name: AppRoutes.mediaPlayer,
      page: () => const MediaPlayerScreen(),
      binding: MediaBinding(),
    ),
    GetPage(
      name: AppRoutes.youtube,
      page: () => const YoutubeScreen(),
      binding: MediaBinding(),
    ),
    GetPage(
      name: AppRoutes.youtubeRoom,
      page: () => const YouTubeRoomScreen(),
      binding: YouTubeBinding(),
    ),
    GetPage(
      name: AppRoutes.playlist,
      page: () => const PlaylistScreen(),
      binding: MediaBinding(),
    ),
    GetPage(
      name: AppRoutes.soundEffects,
      page: () => const SoundEffectsPanel(),
      binding: MediaBinding(),
    ),

    // ─── LEVEL & XP ─────────────────────────────────────
    GetPage(
      name: AppRoutes.levelPage,
      page: () => const LevelScreen(),
      binding: LevelBinding(),
    ),

    // ─── POWER MATRIX ───────────────────────────────────
    GetPage(
      name: AppRoutes.powerMatrix,
      page: () => const PowerMatrixView(),
      binding: PowerMatrixBinding(),
    ),

    // ─── INVENTORY / BACKPACK ───────────────────────────
    GetPage(
      name: AppRoutes.inventory,
      page: () => const InventoryScreen(),
      binding: InventoryBinding(),
    ),

    // ─── SUPPORT & TICKETING ────────────────────────────
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportScreen(),
      binding: SupportBinding(),
    ),

    // ─── SETTINGS & PRIVACY ─────────────────────────────
    GetPage(
      name: AppRoutes.settingsPage,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.privacy,
      page: () => const PrivacyScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.socialLinks,
      page: () => const SocialLinksScreen(),
      binding: SettingsBinding(),
    ),

    // ─── ADMIN PANEL ────────────────────────────────────
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardScreen(),
      middlewares: [AuthGuardMiddleware()],
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adminStaff,
      page: () => const StaffManagementScreen(),
      middlewares: [AuthGuardMiddleware()],
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adminBroadcast,
      page: () => const BroadcastScreen(),
      middlewares: [AuthGuardMiddleware()],
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.walletManagement,
      page: () => const AdminWalletManagementView(),
      middlewares: [AuthGuardMiddleware()],
      binding: AdminBinding(),
    ),

    // ─── GLOBAL ANALYTICS ────────────────────────────────
    GetPage(
      name: AppRoutes.globalAnalytics,
      page: () => const AnalyticsDashboardScreen(),
      middlewares: [AuthGuardMiddleware()],
      binding: AnalyticsBinding(),
    ),

    // ─── ROOMS (filtered list from home "View All") ─────
    GetPage(
      name: AppRoutes.rooms,
      page: () => const RoomListScreen(),
      binding: RoomBinding(),
    ),

    // ─── CHANGE PASSWORD ─────────────────────────────────
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const PasswordResetScreen(),
      binding: AuthBinding(),
    ),

    // ─── ADMIN WITHDRAWALS ──────────────────────────────
    GetPage(
      name: AppRoutes.adminWithdrawals,
      page: () => const AdminWalletManagementView(),
      middlewares: [AuthGuardMiddleware()],
      binding: AdminBinding(),
    ),
  ];
}