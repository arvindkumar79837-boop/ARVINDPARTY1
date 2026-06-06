const express = require('express');
const router = express.Router();
const agencyController = require('../controllers/agencyController');

// Note: You should attach an authentication/role middleware here 
// to ensure only 'Owner' or 'Admin' can access these routes.

// Route to disable an agency
router.post('/disable/:id', agencyController.disableAgency);

// Route to delete an agency
router.delete('/delete/:id', agencyController.deleteAgency);

module.exports = router;