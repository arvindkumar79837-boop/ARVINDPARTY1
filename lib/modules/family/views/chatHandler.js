const Message = require('../models/Message');

// In-memory map to track active user sockets: Map<UserId, SocketId>
const connectedUsers = new Map(); 

module.exports = (io, socket) => {
  
  // 1. Register user when they connect to the chat system
  socket.on('register_user', (data) => {
    const { userId } = data;
    if (userId) {
      connectedUsers.set(userId, socket.id);
      console.log(`User ${userId} registered for private chat on socket ${socket.id}`);
    }
  });

  // 2. Handle sending a private message
  socket.on('send_private_message', async (data) => {
    const { senderId, receiverId, content, messageType } = data;

    try {
      // Save message to MongoDB
      const newMessage = new Message({
        senderId,
        receiverId,
        content,
        messageType: messageType || 'text'
      });
      await newMessage.save();

      // Check if receiver is online and push the message in real-time
      const receiverSocketId = connectedUsers.get(receiverId);
      if (receiverSocketId) {
        io.to(receiverSocketId).emit('receive_private_message', newMessage);
      }

      // Acknowledge success to the sender
      socket.emit('message_sent_ack', { success: true, message: newMessage });

    } catch (error) {
      console.error('Error sending private message:', error);
      socket.emit('message_error', { success: false, error: 'Failed to send message.' });
    }
  });

  socket.on('disconnect', () => {
    // Cleanup: We would iterate connectedUsers and delete the disconnected socket ID here
  });
};