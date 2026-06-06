const mongoose = require('mongoose');

const familySchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  logo: { type: String, default: '' },
  leader: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  members: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  level: { type: Number, default: 1 },
  wealth: { type: Number, default: 0 },
  notice: { type: String, default: 'Welcome to our Family!' },
  status: { type: String, enum: ['active', 'banned'], default: 'active' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Family', familySchema);