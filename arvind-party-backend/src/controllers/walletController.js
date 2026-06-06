const User = require('../models/User');
const WalletTransaction = require('../models/WalletTransaction');

// GET /api/wallet
exports.getWallet = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('coins diamonds userId name');
    const transactions = await WalletTransaction.find({ userId: req.user.id })
      .sort({ createdAt: -1 }).limit(20);
    return res.json({ success: true, coins: user.coins, diamonds: user.diamonds, transactions });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// POST /api/wallet/recharge (payment gateway baad mein lagega)
exports.recharge = async (req, res) => {
  try {
    const { amount, paymentRef } = req.body;
    if (!amount || amount <= 0)
      return res.status(400).json({ success: false, message: 'Invalid amount' });

    const user = await User.findById(req.user.id);
    user.coins += amount;
    await user.save();

    await WalletTransaction.create({
      userId: req.user.id,
      type: 'recharge',
      amount,
      description: `Recharged ${amount} coins`,
      ref: paymentRef || 'manual'
    });

    return res.json({ success: true, coins: user.coins, message: `${amount} coins added!` });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// GET /api/wallet/transactions
exports.getTransactions = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = 20;
    const transactions = await WalletTransaction.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit);
    return res.json({ success: true, transactions });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// GET /api/wallet/withdrawal-info
exports.getWithdrawalInfo = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const user = await User.findById(userId);
    
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Returning structured data for the Flutter UI
    const methods = [
      { id: 'payoneer', name: 'Payoneer', icon: 'assets/images/payoneer.png', minWithdrawalUsd: 50.0, feePercentage: 1.5, processingTime: '1-3 Business Days' },
      { id: 'bank_transfer', name: 'Bank Transfer', icon: 'assets/images/bank.png', minWithdrawalUsd: 100.0, feePercentage: 2.0, processingTime: '3-5 Business Days' },
      { id: 'epay', name: 'Epay', icon: 'assets/images/epay.png', minWithdrawalUsd: 10.0, feePercentage: 1.0, processingTime: 'Instant' }
    ];

    res.status(200).json({ beansBalance: user.coins || 0, methods });
  } catch (error) {
    console.error('Withdrawal Info Error:', error);
    res.status(500).json({ message: 'Failed to load withdrawal info' });
  }
};

// POST /api/wallet/withdraw
exports.withdraw = async (req, res) => {
  try {
    const { methodId, amount } = req.body;
    const userId = req.user.id || req.user.userId;
    const user = await User.findById(userId);

    if (!user) return res.status(404).json({ message: 'User not found' });

    // Exchange rate: e.g., 210 Beans/Coins = $1 USD
    const coinsRequired = amount * 210;
    const currentCoins = user.coins || 0;

    if (currentCoins < coinsRequired) {
      return res.status(400).json({ message: 'Insufficient balance for this withdrawal' });
    }

    user.coins -= coinsRequired;
    await user.save();

    // In production, insert a record into a `WithdrawalRequest` collection for admin approval
    await WalletTransaction.create({
      userId,
      type: 'withdrawal',
      amount: -coinsRequired,
      description: `Withdrawal request of $${amount} via ${methodId}`,
      ref: 'pending'
    });

    res.status(200).json({ message: 'Withdrawal request submitted successfully' });
  } catch (error) {
    console.error('Withdraw Error:', error);
    res.status(500).json({ message: 'Failed to process withdrawal' });
  }
};
