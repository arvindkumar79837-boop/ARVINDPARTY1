const mongoose = require('mongoose');

const agencySchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    ownerUid: { type: String, required: true, unique: true },
    earnings: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
    totalHosts: { type: Number, default: 0 }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Agency', agencySchema);