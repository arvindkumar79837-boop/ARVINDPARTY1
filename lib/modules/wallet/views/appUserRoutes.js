const express = require('express');
const router = express.Router();
const withdrawalController = require('../controllers/withdrawalController');

// This route perfectly matches the endpoint called in your Flutter ProfileController:
// ApiClient().post('/app-users/withdraw', ...)

router.post('/withdraw', withdrawalController.requestWithdrawal);

module.exports = router;