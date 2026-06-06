const User = require('../models/User');
const Family = require('../models/Family');

exports.getMyFamily = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const family = await Family.findOne({ members: userId }).populate('members', 'name avatar').populate('leader', 'name avatar');
    
    if (family) {
      res.status(200).json({ success: true, family, message: "Family data loaded" });
    } else {
      res.status(200).json({ success: true, family: null, message: "No family joined yet" });
    }
  } catch (error) {
    console.error('Get Family Error:', error);
    res.status(500).json({ success: false, message: 'Failed to load family data' });
  }
};

exports.createFamily = async (req, res) => {
  try {
    const { name, logo } = req.body;
    const userId = req.user.id || req.user.userId;
    
    const newFamily = await Family.create({ name, logo, leader: userId, members: [userId] });
    res.status(201).json({ success: true, family: newFamily, message: `Family '${name}' created successfully!` });
  } catch (error) {
    console.error('Create Family Error:', error);
    res.status(500).json({ success: false, message: 'Failed to create family' });
  }
};

exports.joinFamily = async (req, res) => {
  try {
    const { familyId } = req.body;
    const userId = req.user.id || req.user.userId;

    const family = await Family.findByIdAndUpdate(familyId, { $addToSet: { members: userId } }, { new: true });
    if (!family) {
      return res.status(404).json({ success: false, message: 'Family not found' });
    }
    res.status(200).json({ success: true, family, message: 'Joined family successfully' });
  } catch (error) {
    console.error('Join Family Error:', error);
    res.status(500).json({ success: false, message: 'Failed to join family' });
  }
};