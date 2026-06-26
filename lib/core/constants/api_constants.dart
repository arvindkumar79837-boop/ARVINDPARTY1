// ═══════════════════════════════════════════════════════════════════════════
// API CONSTANTS — Environment-based configuration
// ═══════════════════════════════════════════════════════════════════════════
// IMPORTANT: Copy env_config_template.dart to env_config.dart and fill in
// your actual values. DO NOT commit env_config.dart to version control.
// ═══════════════════════════════════════════════════════════════════════════

import 'env_config.dart';

class ApiConstants {
  // Base URLs from env_config
  static String get apiBaseUrl => EnvConfig.apiBaseUrl;
  static String get socketUrl => EnvConfig.socketUrl;

  // ─── AUTH ────────────────────────────────────────────────────────────
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String signup = '$auth/signup';
  static const String phoneLogin = '$auth/phone-login';
  static const String verifyOtp = '$auth/verify-otp';
  static const String googleLogin = '$auth/google';
  static const String appleLogin = '$auth/apple';
  static const String refreshToken = '$auth/refresh-token';

  // ─── USERS ───────────────────────────────────────────────────────────
  static const String users = '/users';

  // ─── ROOMS ───────────────────────────────────────────────────────────
  static const String rooms = '/rooms';

  // ─── CHAT ────────────────────────────────────────────────────────────
  static const String chat = '/chat';

  // ─── GIFTS ────────────────────────────────────────────────────────────
  static const String gifts = '/gifts';

  // ─── WALLET ───────────────────────────────────────────────────────────
  static const String wallet = '/wallet';

  // ─── VIP ─────────────────────────────────────────────────────────────
  static const String vip = '/vip';

  // ─── FAMILY ──────────────────────────────────────────────────────────
  static const String family = '/families';
  static const String familyCreate = '$family/create';
  static const String familyJoin = '$family/join';
  static const String familyLeave = '$family/leave';
  static const String familyMembers = '$family/members';
  static const String familyTasks = '$family/tasks';
  static const String familyTasksComplete = '$family/tasks/complete';
  static const String familyTasksDaily = '$family/tasks/daily';
  static const String familyWars = '$family/wars';
  static const String familyWarCreate = '$family/wars/create';
  static const String familyWarJoin = '$family/wars/join';
  static const String familyRanking = '$family/ranking';
  static const String familyRankingDaily = '$family/ranking/daily';
  static const String familyRankingWeekly = '$family/ranking/weekly';
  static const String familyRankingMonthly = '$family/ranking/monthly';
  static const String familyPoints = '$family/points';
  static const String familyShop = '$family/shop';
  static const String familyShopPurchase = '$family/shop/purchase';
  static const String familyChatHistory = '$family/chat/history';
  static const String familyUpgrade = '$family/upgrade';

  // ─── AGENCY ──────────────────────────────────────────────────────────
  static const String agency = '/agency';

  // ─── EVENTS ──────────────────────────────────────────────────────────
  static const String events = '/events';

  // ─── SHOP ────────────────────────────────────────────────────────────
  static const String shop = '/shop';

  // ─── GAMES ───────────────────────────────────────────────────────────
  static const String games = '/games';

  // ─── PK BATTLES ──────────────────────────────────────────────────────
  static const String pkBattles = '/pk-battles';

  // ─── RANKINGS ────────────────────────────────────────────────────────
  static const String rankings = '/rankings';

  // ─── LEVELS ──────────────────────────────────────────────────────────
  static const String levels = '/level';

  // ─── INVENTORY ───────────────────────────────────────────────────────
  static const String inventory = '/inventory';

  // ─── CREATOR ─────────────────────────────────────────────────────────
  static const String creator = '/creator';

  // ─── SUPPORT ─────────────────────────────────────────────────────────
  static const String support = '/support';

  // ─── MODERATION ──────────────────────────────────────────────────────
  static const String moderation = '/moderation';

  // ─── REFERRALS ───────────────────────────────────────────────────────
  static const String referrals = '/referral';

  // ─── MOMENTS ─────────────────────────────────────────────────────────
  static const String moments = '/moments';

  // ─── NOTIFICATIONS ───────────────────────────────────────────────────
  static const String notifications = '/notifications';

  // ─── ADMIN ──────────────────────────────────────────────────────────
  static const String admin = '/admin';
  static const String adminStats = '$admin/stats';
  static const String adminUsers = '$admin/users';
  static const String adminUserBlock = '$admin/users/block';
  static const String adminUserUnblock = '$admin/users/unblock';
  static const String adminCoinsGenerate = '$admin/coins/generate';
  static const String adminCoinsDeduct = '$admin/coins/deduct';
  static const String adminWithdrawalsPending = '$admin/withdrawals/pending';
  static const String adminWithdrawalApprove = '$admin/withdrawals/approve';
  static const String adminWithdrawalReject = '$admin/withdrawals/reject';
  static const String adminRewardSend = '$admin/rewards/send';

  // ─── STAFF ──────────────────────────────────────────────────────────
  static const String staff = '/staff';
  static const String staffLogin = '$staff/login';
  static const String staffList = '$staff/list';
  static const String staffCreate = '$staff/create';
  static const String staffUpdate = '$staff/update';
  static const String staffDelete = '$staff/delete';
  static const String staffChangePassword = '$staff/change-password';
  static const String staffRoles = '$staff/roles';

  // ─── TREASURY / COIN VAULT ───────────────────────────────────────────
  static const String treasury = '/treasury';
  static const String treasuryVault = '$treasury/vault';
  static const String treasuryMint = '$treasury/vault/mint';
  static const String treasuryDispatch = '$treasury/vault/dispatch';
  static const String treasuryBurn = '$treasury/vault/burn';

  // ─── TARGETS ─────────────────────────────────────────────────────────
  static const String targets = '/targets';
  static const String targetsCreate = '$targets/create';
  static const String targetsApproveExchange = '$targets/approve-exchange';
  static const String targetsAutoCycle = '$targets/auto-cycle';

  // ─── REWARDS ─────────────────────────────────────────────────────────
  static const String rewards = '/rewards';
  static const String rewardsInject = '$rewards/inject';
  static const String rewardsHistory = '$rewards/history';
  static const String rewardsRevoke = '$rewards/revoke';
  static const String rewardsUser = '$rewards/user';

  // ─── COIN ORDERS ─────────────────────────────────────────────────────
  static const String coinOrders = '/coin-orders';

  // ─── SECURITY ────────────────────────────────────────────────────────
  static const String security = '/security';
  static const String securityLogins = '$security/logins';
  static const String securityBlockIp = '$security/block-ip';

  // ─── AGENCY ──────────────────────────────────────────────────────────
  static const String agencyHosts = '$agency/hosts';
  static const String agencyCreation = '$agency/create';
  static const String agencyEarnings = '$agency/earnings';
  static const String agencyCommissionTiers = '$agency/commission-tiers';

  // ─── BLIND DATE ──────────────────────────────────────────────────────
  static const String blindMatch = '/blind-date/match';
  static const String blindMatchStop = '/blind-date/stop';

  // ─── EVENTS ──────────────────────────────────────────────────────────
  static const String eventListing = '$events/listing';
  static const String eventCreation = '$events/create';

  // ─── GAMES ───────────────────────────────────────────────────────────
  static const String luckyWheelSpin = '$games/lucky-wheel/spin';
  static const String scratchCardPlay = '$games/scratch-card/play';
  static const String gameLeaderboard = '$games/leaderboard';

  // ─── LUCKY DRAW ─────────────────────────────────────────────────────
  static const String luckyWheelRewards = '/lucky-draw/rewards';
  static const String luckyWheelSpinDraw = '/lucky-draw/spin';

  // ─── MOMENTS ─────────────────────────────────────────────────────────
  static const String momentsFeed = '$moments/feed';
  static const String postCreation = '$moments/create';
  static const String likeSystem = '$moments/like';
  static const String commentSystem = '$moments/comment';

  // ─── PK BATTLE ───────────────────────────────────────────────────────
  static const String pkRequest = '$pkBattles/request';
  static const String pkAccept = '$pkBattles/accept';
  static const String pkEnd = '$pkBattles/end';

  // ─── RANKINGS ────────────────────────────────────────────────────────
  static const String wealthRanking = '$rankings/wealth';
  static const String charmRanking = '$rankings/charm';
  static const String giftRanking = '$rankings/gift';

  // ─── SEARCH ───────────────────────────────────────────────────────────
  static const String userSearch = '$users/search';

  // ─── SHOP ────────────────────────────────────────────────────────────
  static const String shopItems = '$shop/items';
  static const String shopPurchase = '$shop/purchase';

  // ─── SOCKET EVENTS ───────────────────────────────────────────────────
  static const String socketConnect = 'connect';
  static const String socketDisconnect = 'disconnect';
  static const String socketError = 'error';
  static const String roomJoin = 'room:join';
  static const String roomLeave = 'room:leave';
  static const String roomCreate = 'room:create';
  static const String chatMessage = 'chat:message';
  static const String giftSend = 'gift:send';
  static const String seatUpdate = 'seat:update';
  static const String pkBattle = 'pk:battle';
  static const String vaultUpdate = 'vault:update';
  static const String targetUpdate = 'target:update';
  static const String notificationNew = 'notification:new';
}