const express = require('express');
const router = express.Router();
const roomController = require('../controllers/room.controller');
const auth = require('../../authMiddleware');

router.get('/live', roomController.getLiveRooms);
router.get('/search', roomController.searchRooms);
router.post('/create', auth, roomController.createRoom);
router.post('/:roomId/settings', auth, roomController.updateRoomSettings);

module.exports = router;