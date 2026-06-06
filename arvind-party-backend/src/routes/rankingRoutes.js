const express = require('express');
const router = express.Router();
const rankingController = require('../controllers/rankingController');
const auth = require('../../authMiddleware');

router.get('/wealth', auth, rankingController.getTopWealth);
router.get('/charm', auth, rankingController.getTopCharm);

module.exports = router;