// ═══════════════════════════════════════════════════════════════════════════
// MODEL: Staff — 15+ Role Matrix for platform positions
// Owner, Admins, Global/Country Managers, BD Staff, Super/Normal Coin Sellers,
// Customer Service Teams, Assistants
// ═══════════════════════════════════════════════════════════════════════════

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Complete role hierarchy: each level inherits permissions from lower levels
const ROLE_HIERARCHY = {
  owner: { level: 100, label: 'Owner' },
  super_admin: { level: 90, label: 'Super Admin' },
  admin: { level: 80, label: 'Admin' },
  global_manager: { level: 70, label: 'Global Manager' },
  country_manager: { level: 60, label: 'Country Manager' },
  bd_staff: { level: 50, label: 'BD Staff' },
  super_coin_seller: { level: 45, label: 'Super Coin Seller' },
  normal_coin_seller: { level: 40, label: 'Normal Coin Seller' },
  customer_service_manager: { level: 35, label: 'CS Manager' },
  customer_service_senior: { level: 30, label: 'Senior CS' },
  customer_service: { level: 25, label: 'Customer Service' },
  assistant_manager: { level: 20, label: 'Assistant Manager' },
  assistant_senior: { level: 15, label: 'Senior Assistant' },
  assistant: { level: 10, label: 'Assistant' },
  moderator: { level: 5, label: 'Moderator' },
};

const ROLES = Object.keys(ROLE_HIERARCHY);

// All available permissions in the system
const ALL_PERMISSIONS = [
  'dashboard.view',
  'users.view', 'users.edit', 'users.ban', 'users.delete',
  'users.verify', 'users.adjust_coins',
  'rooms.view', 'rooms.edit', 'rooms.delete',
  'rooms.moderate',
  'wallet.view', 'wallet.adjust', 'wallet.withdrawal_approve',
  'wallet.withdrawal_reject',
  'gifts.view', 'gifts.edit', 'gifts.delete',
  'treasury.view', 'treasury.mint', 'treasury.dispatch', 'treasury.burn',
  'rewards.inject', 'rewards.revoke',
  'staff.view', 'staff.create', 'staff.edit', 'staff.delete',
  'staff.change_password',
  'agency.view', 'agency.approve', 'agency.edit', 'agency.delete',
  'family.view', 'family.edit', 'family.delete',
  'events.view', 'events.create', 'events.edit', 'events.delete',
  'reports.view', 'reports.resolve',
  'vip.view', 'vip.edit',
  'notifications.send',
  'settings.view', 'settings.edit',
  'audit.view',
  'leaderboard.view', 'leaderboard.reset',
  'support.view', 'support.reply',
  'moments.view', 'moments.delete',
  'announcements.send',
  'security.view', 'security.block_ip',
  'coin_orders.view',
  'targets.view', 'targets.create', 'targets.approve_exchange',
  'targets.auto_cycle',
  'commission.view', 'commission.edit',
];

// Default permissions per role
const DEFAULT_PERMISSIONS = {
  owner: ALL_PERMISSIONS,
  super_admin: ALL_PERMISSIONS.filter(p => !['treasury.mint', 'treasury.dispatch', 'treasury.burn', 'staff.change_password', 'staff.delete'].includes(p)),
  admin: ALL_PERMISSIONS.filter(p => !['treasury.mint', 'treasury.dispatch', 'treasury.burn', 'staff.create', 'staff.edit', 'staff.delete', 'staff.change_password', 'settings.edit', 'leaderboard.reset', 'security.block_ip'].includes(p)),
  global_manager: ['dashboard.view', 'users.view', 'users.edit', 'rooms.view', 'rooms.edit', 'wallet.view', 'gifts.view', 'agency.view', 'family.view', 'events.view', 'reports.view', 'vip.view', 'support.view', 'support.reply', 'moments.view', 'leaderboard.view', 'targets.view', 'commission.view'],
  country_manager: ['dashboard.view', 'users.view', 'rooms.view', 'wallet.view', 'gifts.view', 'agency.view', 'family.view', 'events.view', 'reports.view', 'support.view', 'support.reply', 'leaderboard.view'],
  bd_staff: ['dashboard.view', 'users.view', 'rooms.view', 'agency.view', 'events.view', 'leaderboard.view'],
  super_coin_seller: ['dashboard.view', 'users.view', 'coin_orders.view', 'wallet.view'],
  normal_coin_seller: ['dashboard.view', 'coin_orders.view'],
  customer_service_manager: ['dashboard.view', 'users.view', 'support.view', 'support.reply', 'reports.view', 'reports.resolve', 'notifications.send'],
  customer_service_senior: ['users.view', 'support.view', 'support.reply', 'reports.view'],
  customer_service: ['users.view', 'support.view', 'support.reply'],
  assistant_manager: ['dashboard.view', 'users.view', 'rooms.view', 'rooms.moderate', 'events.view', 'notifications.send'],
  assistant_senior: ['users.view', 'rooms.view', 'rooms.moderate'],
  assistant: ['users.view'],
  moderator: ['rooms.view', 'rooms.moderate', 'users.view', 'reports.view'],
};

const staffSchema = new mongoose.Schema(
  {
    uid: { type: String, required: true, unique: true },
    loginId: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    name: { type: String, default: '' },
    email: { type: String, default: '' },
    phone: { type: String, default: '' },
    avatar: { type: String, default: '' },
    role: {
      type: String,
      enum: ROLES,
      required: true,
      default: 'assistant',
    },
    roleLevel: { type: Number, default: 0 }, // Computed from ROLE_HIERARCHY
    permissions: [{ type: String }],
    isActive: { type: Boolean, default: true },
    isOwnerLocked: { type: Boolean, default: false }, // Owner-enforced password lock
    lastLoginAt: { type: Date },
    loginHistory: [
      {
        ip: String,
        userAgent: String,
        timestamp: { type: Date, default: Date.now },
      },
    ],
    assignedCountry: { type: String, default: '' }, // For country managers
    createdBy: { type: String, default: '' },
    notes: { type: String, default: '' },
  },
  { timestamps: true }
);

staffSchema.index({ role: 1 });
staffSchema.index({ isActive: 1 });
staffSchema.index({ roleLevel: 1 });

// Pre-save: compute roleLevel and set default permissions
staffSchema.pre('save', function (next) {
  if (this.role && ROLE_HIERARCHY[this.role]) {
    this.roleLevel = ROLE_HIERARCHY[this.role].level;
  }
  if (!this.permissions || this.permissions.length === 0) {
    this.permissions = DEFAULT_PERMISSIONS[this.role] || [];
  }
  next();
});

// Static: Get role hierarchy detail
staffSchema.statics.getRoleHierarchy = function () {
  return ROLE_HIERARCHY;
};

// Static: Get all valid roles
staffSchema.statics.getRoles = function () {
  return ROLES;
};

// Static: Get default permissions for a role
staffSchema.statics.getDefaultPermissions = function (role) {
  return DEFAULT_PERMISSIONS[role] || [];
};

// Static: Check if a role has sufficient level
staffSchema.statics.hasSufficientLevel = function (userRoleLevel, requiredRole) {
  const requiredLevel = ROLE_HIERARCHY[requiredRole]?.level || 0;
  return userRoleLevel >= requiredLevel;
};

module.exports = mongoose.model('Staff', staffSchema);
module.exports.ROLE_HIERARCHY = ROLE_HIERARCHY;
module.exports.ROLES = ROLES;
module.exports.ALL_PERMISSIONS = ALL_PERMISSIONS;
module.exports.DEFAULT_PERMISSIONS = DEFAULT_PERMISSIONS;