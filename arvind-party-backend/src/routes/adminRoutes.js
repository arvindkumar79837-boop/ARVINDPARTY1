const express = require('express');
const router = express.Router();
const { requirePermission, verifyStaff, verifyOwner } = require('../middlewares/adminMiddleware');
const adminController = require('../controllers/adminController');

// 👥 GET ALL APP USERS (Requires 'USER_VIEW' Permission)
// Only Owner OR Staff with USER_VIEW can access this
router.get('/users', requirePermission('USER_VIEW'), adminController.getAllUsers);

// 🚫 BAN/UNBAN USER (Requires 'USER_BAN' Permission)
router.post('/users/block/:id', requirePermission('USER_BAN'), adminController.toggleBlockUser);

// 📊 GET DASHBOARD STATS (Any Staff can view)
router.get('/stats', verifyStaff, adminController.getStats);

// 🏠 ROOM MANAGEMENT
router.get('/rooms', requirePermission('ROOM_VIEW'), adminController.getAllRooms);

// 🚫 FORCE CLOSE ROOM (Requires 'ROOM_CLOSE' Permission)
router.post('/rooms/close/:id', requirePermission('ROOM_CLOSE'), adminController.closeRoom);

// ⚙️ SYSTEM SETTINGS (Owner Only for updates)
router.get('/settings', verifyStaff, adminController.getSettings);
router.post('/settings', verifyOwner, adminController.updateSettings);

// 🏢 AGENCY CONTROL
router.get('/agencies', verifyStaff, adminController.getAgencies);
router.post('/agencies', verifyOwner, adminController.createAgency);
router.get('/agencies/:id/hosts', verifyStaff, adminController.getAgencyHosts);

// 💸 WITHDRAWALS (Owner Only)
router.get('/withdrawals', verifyStaff, adminController.getWithdrawals);
router.post('/withdrawals/:id/process', verifyOwner, adminController.processWithdrawal);

module.exports = router;