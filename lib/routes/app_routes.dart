abstract class AppRoutes {
  // ═══════ CORE AUTH ═══════
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const phoneAuth = '/phone-auth';
  static const otp = '/otp-screen';
  static const emailLogin = '/email-login';
  static const googleLogin = '/google-login';
  static const facebookLogin = '/facebook-login';
  static const appleLogin = '/apple-login';
  static const guestLogin = '/guest-login';
  static const passwordReset = '/password-reset';
  static const deviceBinding = '/device-binding';
  static const sessionManagement = '/session-management';
  static const multiDeviceControl = '/multi-device-control';
  static const accountSecurity = '/account-security';
  static const securityCenter = '/security-center';
  static const completeProfile = '/complete-profile';

  // ═══════ VIP ═══════
  static const vip = '/vip';
  static const vipDashboard = '/vip-dashboard';
  static const vipShop = '/vip-shop';
  static const vipMissions = '/vip-missions';
  static const vipCosmetics = '/vip-cosmetics';
  static const vipLeaderboard = '/vip-leaderboard';
  static const premium = '/premium';

  // ═══════ USER PROFILE ═══════
  static const home = '/home';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const userProfile = '/user-profile';
  static const userCenter = '/user-center';

  // ═══════ SOCIAL ═══════
  static const friends = '/friends';
  static const friendSearch = '/friend-search';
  static const blacklist = '/blacklist';
  static const blockList = '/block-list';
  static const visitorHistory = '/visitor-history';

  // ═══════ CHAT ═══════
  static const chat = '/chat';
  static const privateChat = '/private-chat';

  // ═══════ ROOM ═══════
  static const roomList = '/room-list';
  static const roomDetail = '/room-detail';
  static const liveRoom = '/live-room';
  static const createRoom = '/create-room';
  static const voiceRoom = '/voice-room';
  static const rooms = '/rooms';
  static const hostControls = '/host-controls';
  static const coHostControls = '/co-host-controls';
  static const moderatorControls = '/moderator-controls';
  static const roomLock = '/room-lock';
  static const roomBackground = '/room-background';
  static const roomAnalytics = '/room-analytics';

  // ═══════ GIFT ═══════
  static const giftShop = '/gift-shop';
  static const giftStatistics = '/gift-statistics';
  static const giftLeaderboard = '/gift-leaderboard';
  static const giftRanking = '/gift-ranking';

  // ═══════ WALLET ═══════
  static const wallet = '/wallet';
  static const coinWallet = '/coin-wallet';
  static const diamondWallet = '/diamond-wallet';
  static const rewardWallet = '/reward-wallet';
  static const treasuryPanel = '/treasury-panel';
  static const withdrawal = '/withdrawal';
  static const withdrawalManagement = '/withdrawal-management';
  static const walletHistory = '/wallet-history';
  static const walletManagement = '/wallet-management';
  static const paymentSuccess = '/payment-success';

  // ═══════ LEVEL ═══════
  static const levelPage = '/level';

  // ═══════ RANKING ═══════
  static const wealthRanking = '/wealth-ranking';
  static const charmRanking = '/charm-ranking';
  static const agencyRanking = '/agency-ranking';
  static const familyRankingPage = '/family-ranking-page';

  // ═══════ GAMES ═══════
  static const games = '/games';
  static const gameCenter = '/game-center';
  static const luckyNumber = '/lucky-number';
  static const diceGame = '/dice-game';
  static const miniCompetitions = '/mini-competitions';
  static const luckySpin = '/lucky-spin';
  static const drawHistory = '/draw-history';

  // ═══════ EVENTS & MISSIONS ═══════
  static const eventListing = '/event-listing';
  static const eventHistory = '/event-history';
  static const dailyMissions = '/daily-missions';

  // ═══════ NOTIFICATION ═══════
  static const notifications = '/notifications';

  // ═══════ MEDIA ═══════
  static const youtube = '/youtube';
  static const playlist = '/playlist';
  static const mediaPlayer = '/media-player';
  static const soundEffects = '/sound-effects';

  // ═══════ FAMILY ═══════
  static const family = '/family';
  static const familyCreation = '/family-creation';
  static const familyChat = '/family-chat';
  static const familyMembers = '/family-members';
  static const familyTasks = '/family-tasks';
  static const familyWars = '/family-wars';
  static const familyWallet = '/family-wallet';

  // ═══════ AGENCY ═══════
  static const agency = '/agency';
  static const agencyCreation = '/agency-creation';
  static const agencyHosts = '/agency-hosts';
  static const agencyEarnings = '/agency-earnings';
  static const agencyWallet = '/agency-wallet';
  static const agencyLeaderboard = '/agency-leaderboard';

  // ═══════ COIN SELLER ═══════
  static const coinSeller = '/coin-seller';
  static const coinSellerProfile = '/coin-seller-profile';
  static const coinSellerRanking = '/coin-seller-ranking';
  static const coinSellerTransactions = '/coin-seller-transactions';
  static const rechargeHistory = '/recharge-history-cs';
  static const settlementHistory = '/settlement-history';
  static const dealerWallet = '/dealer-wallet';

  // ═══════ ADMIN ═══════
  static const adminDashboard = '/admin';
  static const adminStaff = '/admin/staff';
  static const adminBroadcast = '/admin/broadcast';
  static const adminWithdrawals = '/admin/withdrawals';
  static const globalAnalytics = '/global-analytics';

  // ═══════ SHOP ═══════
  static const shop = '/shop';
  static const inventory = '/inventory';

  // ═══════ SETTINGS ═══════
  static const settingsPage = '/settings';
  static const changePassword = '/change-password';
  static const support = '/support';
  static const privacy = '/privacy';
  static const socialLinks = '/social-links';
  static const gallery = '/gallery';
  static const search = '/search';
}
