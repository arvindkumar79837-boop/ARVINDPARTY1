const express = require('express');
const http = require('http');
const mongoose = require('mongoose');
const cors = require('cors');
const { Server } = require('socket.io');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./src/routes/userRoutes');
const roomRoutes = require('../lib/modules/auth/controllers/roomRoutes');
const treasuryRoutes = require('./src/routes/treasuryRoutes');
const staffRoutes = require('./src/routes/staffRoutes');
const adminRoutes = require('./src/routes/adminRoutes');
const appUserRoutes = require('./src/routes/appUserRoutes');

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: '*',
  }
});

// Make `io` accessible globally inside controllers
app.set('io', io);

// Middleware
app.use(cors());
app.use(express.json()); // Parses incoming JSON payloads

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/rooms', roomRoutes);
app.use('/api/treasury', treasuryRoutes);
app.use('/api/staff', staffRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/app-users', appUserRoutes);

// Root Endpoint
app.get('/', (req, res) => {
  res.send('Arvind Party Backend is live!');
});

// Socket.IO Real-time Logic
io.on('connection', (socket) => {
  console.log(`User connected: ${socket.id}`);

  socket.on('join_room', (roomId) => {
    socket.join(roomId);
    console.log(`User ${socket.id} joined room ${roomId}`);
  });

  socket.on('send_message', (data) => {
    // Broadcast the message to everyone in the room
    io.to(data.roomId).emit('receive_message', data);
  });

  socket.on('disconnect', () => {
    console.log(`User disconnected: ${socket.id}`);
  });
});

// Database connection & Server initialization
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/arvind_party';

mongoose.connect(MONGO_URI)
  .then(() => {
    console.log('✅ MongoDB Connected Successfully');
    server.listen(PORT, () => {
      console.log(`🚀 Arvind Party Backend is running on port ${PORT}`);
    });
  })
  .catch((err) => console.error('❌ MongoDB Connection Error:', err));