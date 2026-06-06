const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const Staff = require('../models/Staff');

exports.createStaff = async (req, res) => {
  try {
    const { uid, loginId, password, role, permissions } = req.body;

    if (!uid || !loginId || !password || !role) {
      return res.status(400).json({ success: false, message: 'Missing required credentials or role' });
    }

    // Check if staff already exists
    const existingStaff = await Staff.findOne({ $or: [{ uid }, { loginId }] });
    if (existingStaff) {
      return res.status(400).json({ success: false, message: 'Staff with this UID or Login ID already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newStaff = new Staff({
      uid,
      loginId,
      password: hashedPassword,
      role,
      permissions
    });
    await newStaff.save();

    return res.status(200).json({
      success: true,
      message: `Staff account successfully created for UID: ${uid}`,
      data: {
        uid, loginId, role, permissions
      }
    });
  } catch (error) {
    console.error('Staff Creation Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

exports.loginStaff = async (req, res) => {
  try {
    const { loginId, password } = req.body;

    if (!loginId || !password) {
      return res.status(400).json({ success: false, message: 'Missing loginId or password' });
    }

    const staff = await Staff.findOne({ loginId });
    if (!staff) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    if (!staff.isActive) {
      return res.status(403).json({ success: false, message: 'Account is disabled. Contact Owner.' });
    }

    const isMatch = await bcrypt.compare(password, staff.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    // Embed role and permissions in JWT token payload
    const token = jwt.sign(
      {
        id: staff._id,
        uid: staff.uid,
        role: staff.role,
        isStaff: true,
        permissions: staff.permissions
      },
      process.env.JWT_SECRET || 'arvind_party_super_secret_key',
      { expiresIn: '24h' }
    );

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      staff: {
        uid: staff.uid,
        loginId: staff.loginId,
        role: staff.role,
        permissions: staff.permissions
      }
    });
  } catch (error) {
    console.error('Staff Login Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};