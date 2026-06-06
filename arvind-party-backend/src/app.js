const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const authController = require('./controllers/auth.controller');
const shopRoutes = require('./routes/shopRoutes');
const matchmakingRoutes = require('./routes/matchmakingRoutes');
const userRoutes = require('./routes/userRoutes');
const roomRoutes = require('./routes/roomRoutes');
const walletRoutes = require('./routes/walletRoutes');
const giftRoutes = require('./routes/giftRoutes');
const familyRoutes = require('./routes/familyRoutes');
const agencyRoutes = require('./routes/agencyRoutes');
const rankingRoutes = require('./routes/rankingRoutes');
const cpRoutes = require('./routes/cpRoutes');
const vipRoutes = require('./routes/vipRoutes');
const adminRoutes = require('./routes/adminRoutes');

// Initialize Express App
const app = express();

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Database Connection
mongoose.connect(process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/arvind_party', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => {
  console.log('✅ MongoDB Connected successfully.');
}).catch((err) => {
  console.error('❌ MongoDB Connection Error:', err);
});

// API Routes
const apiRouter = express.Router();

// Auth Routes
apiRouter.post('/auth/login', authController.login);
apiRouter.post('/auth/send-otp', authController.sendOtp);
apiRouter.post('/auth/verify-otp', authController.verifyOtp);

// Register API router
apiRouter.use('/shop', shopRoutes);
apiRouter.use('/matchmaking', matchmakingRoutes);
apiRouter.use('/users', userRoutes);
apiRouter.use('/rooms', roomRoutes);
apiRouter.use('/wallet', walletRoutes);
apiRouter.use('/gifts', giftRoutes);
apiRouter.use('/family', familyRoutes);
apiRouter.use('/agency', agencyRoutes);
apiRouter.use('/rankings', rankingRoutes);
apiRouter.use('/cp', cpRoutes);
apiRouter.use('/vip', vipRoutes);
apiRouter.use('/admin', adminRoutes);
app.use('/api', apiRouter);

// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Arvind Party Backend is running on port ${PORT}`);
});

module.exports = app;