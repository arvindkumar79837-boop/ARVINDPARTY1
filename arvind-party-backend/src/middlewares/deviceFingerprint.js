// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/middlewares/deviceFingerprint.js
// ARVIND PARTY - DEVICE FINGERPRINTING MIDDLEWARE
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Middleware to validate device fingerprints
 * Prevents unauthorized access from suspicious devices
 */

/**
 * @desc Extract device fingerprint from request headers
 * @param {Object} req - Express request object
 * @returns {String} Device fingerprint
 */
const extractDeviceFingerprint = (req) => {
  // Check multiple header locations for fingerprint
  return (
    req.headers['x-device-fingerprint'] ||
    req.headers['X-Device-Fingerprint'] ||
    req.body?.deviceFingerprint ||
    req.query?.deviceFingerprint ||
    null
  );
};

/**
 * @desc Extract device info from request headers
 * @param {Object} req - Express request object
 * @returns {Object} Device information
 */
const extractDeviceInfo = (req) => {
  return {
    userAgent: req.headers['user-agent'] || req.headers['User-Agent'],
    platform: req.headers['x-platform'] || req.headers['X-Platform'],
    deviceId: req.headers['x-device-id'] || req.headers['X-Device-Id'],
    appVersion: req.headers['x-app-version'] || req.headers['X-App-Version'],
  };
};

/**
 * @desc Middleware to validate device fingerprint
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const validateDeviceFingerprint = async (req, res, next) => {
  try {
    // Skip validation for certain routes (login, register, public)
    const publicRoutes = ['/auth/login', '/auth/register', '/auth/verify-otp', '/'];
    const currentPath = req.path;
    
    if (publicRoutes.some(route => currentPath.startsWith(route))) {
      return next();
    }

    const fingerprint = extractDeviceFingerprint(req);
    
    // For development/testing, allow requests without fingerprint
    if (process.env.NODE_ENV === 'development' && !fingerprint) {
      return next();
    }

    // Block requests without fingerprint in production
    if (!fingerprint && process.env.NODE_ENV === 'production') {
      return res.status(403).json({
        success: false,
        message: 'Device fingerprint required',
        code: 'DEVICE_FINGERPRINT_MISSING',
      });
    }

    // If fingerprint exists, validate it
    if (fingerprint) {
      const User = require('../models/User');
      const userId = req.user?.id || req.userId;

      if (userId) {
        // Get user's registered devices
        const user = await User.findById(userId).select('registeredDevices');
        
        if (user?.registeredDevices?.length > 0) {
          // Check if this device is registered
          const isRegistered = user.registeredDevices.some(
            device => device.fingerprint === fingerprint
          );

          if (!isRegistered) {
            // New device detected - log this for security monitoring
            console.log(`[DeviceFingerprint] New device detected for user ${userId}: ${fingerprint}`);
            
            // In production, you might want to:
            // 1. Send verification email/SMS
            // 2. Block the request
            // 3. Flag account for review
            
            // For now, we'll allow but log it
            req.newDeviceDetected = true;
            req.deviceFingerprint = fingerprint;
          }
        } else {
          // No registered devices - first login
          req.newDeviceDetected = true;
          req.deviceFingerprint = fingerprint;
        }
      }

      // Attach fingerprint to request for later use
      req.deviceFingerprint = fingerprint;
    }

    next();
  } catch (error) {
    console.error('[DeviceFingerprint] Middleware error:', error);
    // Don't block on errors, but log them
    next();
  }
};

/**
 * @desc Register device fingerprint for user
 * @param {String} userId - User ID
 * @param {String} fingerprint - Device fingerprint
 * @param {Object} deviceInfo - Device information
 * @returns {Promise<Boolean>} Success status
 */
const registerDeviceFingerprint = async (userId, fingerprint, deviceInfo = {}) => {
  try {
    if (!fingerprint) return false;

    const User = require('../models/User');
    
    const user = await User.findById(userId);
    if (!user) return false;

    // Initialize registeredDevices array if not exists
    if (!user.registeredDevices) {
      user.registeredDevices = [];
    }

    // Check if device already registered
    const existingIndex = user.registeredDevices.findIndex(
      device => device.fingerprint === fingerprint
    );

    if (existingIndex >= 0) {
      // Update existing device
      user.registeredDevices[existingIndex].lastUsed = new Date();
      user.registeredDevices[existingIndex].deviceInfo = {
        ...user.registeredDevices[existingIndex].deviceInfo,
        ...deviceInfo,
      };
    } else {
      // Add new device
      user.registeredDevices.push({
        fingerprint,
        deviceInfo,
        registeredAt: new Date(),
        lastUsed: new Date(),
        isTrusted: false,
      });
    }

    // Limit to 10 registered devices per user
    if (user.registeredDevices.length > 10) {
      user.registeredDevices = user.registeredDevices.slice(-10);
    }

    await user.save();
    console.log(`[DeviceFingerprint] Device registered for user ${userId}: ${fingerprint}`);
    return true;
  } catch (error) {
    console.error('[DeviceFingerprint] Registration error:', error);
    return false;
  }
};

/**
 * @desc Remove device fingerprint for user
 * @param {String} userId - User ID
 * @param {String} fingerprint - Device fingerprint to remove
 * @returns {Promise<Boolean>} Success status
 */
const removeDeviceFingerprint = async (userId, fingerprint) => {
  try {
    const User = require('../models/User');
    
    const user = await User.findById(userId);
    if (!user) return false;

    if (user.registeredDevices) {
      user.registeredDevices = user.registeredDevices.filter(
        device => device.fingerprint !== fingerprint
      );
      await user.save();
      console.log(`[DeviceFingerprint] Device removed for user ${userId}: ${fingerprint}`);
      return true;
    }

    return false;
  } catch (error) {
    console.error('[DeviceFingerprint] Removal error:', error);
    return false;
  }
};

module.exports = {
  validateDeviceFingerprint,
  extractDeviceFingerprint,
  extractDeviceInfo,
  registerDeviceFingerprint,
  removeDeviceFingerprint,
};