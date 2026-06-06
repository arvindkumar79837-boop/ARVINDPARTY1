const Agency = require('../models/Agency');
const User = require('../models/User');

// Disable an Agency
exports.disableAgency = async (req, res) => {
  try {
    const { id } = req.params;

    // Find agency by document _id and set isActive to false
    const agency = await Agency.findByIdAndUpdate(
      id,
      { isActive: false },
      { new: true }
    );

    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found' });
    }

    res.status(200).json({ success: true, message: 'Agency disabled successfully', data: agency });
  } catch (error) {
    console.error('Error disabling agency:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// Delete an Agency
exports.deleteAgency = async (req, res) => {
  try {
    const { id } = req.params;

    // Remove the agency from the database
    const agency = await Agency.findByIdAndDelete(id);

    if (!agency) {
      return res.status(404).json({ success: false, message: 'Agency not found' });
    }

    // Cascade update: Remove this agency's ID from all users who joined it
    await User.updateMany(
      { agencyId: agency.agencyId },
      { $set: { agencyId: null } }
    );

    res.status(200).json({ success: true, message: 'Agency deleted successfully' });
  } catch (error) {
    console.error('Error deleting agency:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};