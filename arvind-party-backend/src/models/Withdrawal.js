const mongoose = require('mongoose');

const withdrawalSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    amountUSD: { type: Number, required: true }, // Kitne dollars ka cashout
    coinsDeducted: { type: Number, required: true }, // Kitne coins deduct hue
    status: { type: String, enum: ['PENDING', 'APPROVED', 'REJECTED'], default: 'PENDING' },
    paymentDetails: { type: String, required: true } // Bank, UPI ya PayPal Details
  },
  { timestamps: true }
);

module.exports = mongoose.model('Withdrawal', withdrawalSchema);