const Room = require('../models/Room');

module.exports = (io) => {
  io.on('connection', (socket) => {
    
    // User joins a live voice room
    socket.on('join_room', async ({ roomId, userId, userProfile }) => {
      socket.join(roomId);
      
      // Increment active users in the MongoDB database
      await Room.findByIdAndUpdate(roomId, { $inc: { activeUsers: 1 } });
      
      // Notify others in the room
      socket.to(roomId).emit('user_joined', { userId, userProfile, message: `${userProfile?.name || 'A user'} entered the room` });
    });

    // User leaves a voice room
    socket.on('leave_room', async ({ roomId, userId, userProfile }) => {
      socket.leave(roomId);
      
      // Decrement active users in the database
      await Room.findByIdAndUpdate(roomId, { $inc: { activeUsers: -1 } });
      
      socket.to(roomId).emit('user_left', { userId, userProfile, message: `${userProfile?.name || 'A user'} left the room` });
    });
    
    // Mic status toggle (mute/unmute)
    socket.on('toggle_mic', ({ roomId, userId, isMuted }) => {
      io.to(roomId).emit('mic_status_changed', { userId, isMuted });
    });
  });
};