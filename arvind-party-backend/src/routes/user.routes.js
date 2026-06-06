const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const auth = require('../middleware/auth.middleware');

router.post('/complete-profile', auth, userController.updateProfile);

module.exports = router;