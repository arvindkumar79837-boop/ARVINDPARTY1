const Room = require('../../Room');

// Fetch active live rooms for the HomeScreen Discovery Feed
exports.getLiveRooms = async (req, res) => {
  try {
    const rooms = await Room.find({ status: 'live' })
      .populate('ownerId', 'name avatar') // Join with user to get owner details
      .sort({ activeUsers: -1 })          // Most active rooms at the top
      .limit(50);                         // Pagination limit
      
    res.status(200).json(rooms);
  } catch (error) {
    console.error('Fetch Live Rooms Error:', error);
    res.status(500).json({ error: 'Failed to fetch live rooms' });
  }
};

// Process new room creation from CreateRoomScreen
exports.createRoom = async (req, res) => {
  try {
    const { name, coverImage, tags, maxUsers } = req.body;
    const ownerId = req.user.userId;
    
    const room = new Room({ name, ownerId, coverImage, tags, maxUsers });
    await room.save();
    
    res.status(201).json({ message: 'Room created successfully', room });
  } catch (error) {
    console.error('Create Room Error:', error);
    res.status(500).json({ error: 'Failed to create room' });
  }
};

// Search for rooms by name or tags
exports.searchRooms = async (req, res) => {
  try {
    const { q } = req.query;
    const rooms = await Room.find({ 
      status: 'live',
      name: { $regex: q, $options: 'i' } // Case-insensitive partial match
    })
    .populate('ownerId', 'name avatar')
    .limit(20);
    
    res.status(200).json(rooms);
  } catch (error) {
    console.error('Search Rooms Error:', error);
    res.status(500).json({ error: 'Failed to search rooms' });
  }
};

// Update room settings
exports.updateRoomSettings = async (req, res) => {
  try {
    const { roomId } = req.params;
    const updateData = req.body;
    const userId = req.user.userId;

    // Verify room exists and user is owner
    const room = await Room.findOneAndUpdate(
      { _id: roomId, ownerId: userId },
      { $set: updateData },
      { new: true }
    );

    if (!room) {
      return res.status(404).json({ message: 'Room not found or unauthorized' });
    }

    res.status(200).json({ message: 'Room settings updated successfully', room });
  } catch (error) {
    console.error('Update Room Settings Error:', error);
    res.status(500).json({ message: 'Failed to update room settings' });
  }
};