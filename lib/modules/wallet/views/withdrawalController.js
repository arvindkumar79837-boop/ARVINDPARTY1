const User = require('../models/User');
const Withdrawal = require('../models/Withdrawal');

// Configuration: Define your platform's exchange rate here
// Example: 1000 Coins = $1.00 USD
const COIN_EXCHANGE_RATE = 0.001; 

exports.requestWithdrawal = async (req, res) => {
  try {
    const { userId, coins, paymentDetails } = req.body;

    if (!userId || !coins || !paymentDetails) {
      return res.status(400).json({ success: false, message: 'Missing required parameters.' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    if (user.coins < coins) {
      return res.status(400).json({ success: false, message: 'Insufficient coin balance.' });
    }

    // 1. Deduct coins from user immediately to prevent double spending
    user.coins -= coins;
    await user.save();

    // 2. Create the pending withdrawal record
    const withdrawal = new Withdrawal({
      userId: user._id,
      coinsDeducted: coins,
      amountUSD: coins * COIN_EXCHANGE_RATE,
      paymentDetails: paymentDetails,
      status: 'pending'
    });
    await withdrawal.save();

    res.status(200).json({ success: true, message: 'Withdrawal request submitted successfully.', data: withdrawal });
  } catch (error) {
    console.error('Error in requestWithdrawal:', error);
    res.status(500).json({ success: false, message: 'Server error processing cash out.' });
  }
};

// --- ADMIN METHODS ---

// Get all withdrawals for the admin panel
exports.getAllWithdrawals = async (req, res) => {
  try {
    // Populate user details to display in the Web Panel
    const withdrawals = await Withdrawal.find().populate('userId', 'name uid avatar').sort({ createdAt: -1 });
    res.status(200).json({ success: true, data: withdrawals });
  } catch (error) {
    console.error('Error fetching withdrawals:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// Approve or Reject a withdrawal
exports.updateWithdrawalStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, adminName } = req.body; // status: 'approved' | 'rejected' | 'completed'

    const withdrawal = await Withdrawal.findById(id);
    if (!withdrawal) {
      return res.status(404).json({ success: false, message: 'Withdrawal not found' });
    }

    withdrawal.status = status;
    withdrawal.processedBy = adminName || 'Admin';
    await withdrawal.save();

    // If rejected, refund the coins back to the user's wallet
    if (status === 'rejected') {
      const user = await User.findById(withdrawal.userId);
      if (user) {
        user.coins += withdrawal.coinsDeducted;
        await user.save();
      }
    }

    res.status(200).json({ success: true, message: `Withdrawal marked as ${status}`, data: withdrawal });
  } catch (error) {
    console.error('Error updating withdrawal:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};