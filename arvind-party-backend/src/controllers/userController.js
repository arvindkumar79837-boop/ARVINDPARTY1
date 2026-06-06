const User = require('../models/User'); // Pulls from your existing User Schema

exports.updateProfile = async (req, res) => {
  try {
    const { name, avatar } = req.body;
    const userId = req.user.userId;

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'User not found' });

    // Update properties
    if (name) user.name = name;
    if (avatar) user.avatar = avatar; // We will accept Base64 string for now
    user.isProfileComplete = true;

    await user.save();

    res.status(200).json({
      message: 'Profile updated successfully',
      user: {
        name: user.name,
        avatar: user.avatar,
        isProfileComplete: user.isProfileComplete
      }
    });
  } catch (error) {
    console.error('Update Profile Error:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

exports.getUserCenter = async (req, res) => {
  try {
    const userId = req.user.userId;
    const user = await User.findById(userId);
    
    // Returning real structured response for the app to render dynamically
    res.status(200).json({
      levelInfo: { currentLevel: user?.level || 1, currentExp: 0, nextLevelExp: 100 },
      badges: [
        { id: 'b1', name: 'Top Gifter', description: 'Gifted over 10k diamonds', iconPath: '💎', isUnlocked: false }
      ],
      frames: [
        { id: 'f1', name: 'Default Ring', imagePath: 'ring', isUnlocked: true, isEquipped: user?.equippedFrame === 'f1' }
      ]
    });
  } catch (error) {
    console.error('User Center Error:', error);
    res.status(500).json({ error: 'Failed to load user center data' });
  }
};

exports.equipFrame = async (req, res) => {
  try {
    const { frameId } = req.body;
    const userId = req.user.userId;
    
    await User.findByIdAndUpdate(userId, { equippedFrame: frameId });
    
    res.status(200).json({ message: 'Frame equipped successfully', frameId });
  } catch (error) {
    console.error('Equip Frame Error:', error);
    res.status(500).json({ error: 'Failed to equip frame' });
  }
};