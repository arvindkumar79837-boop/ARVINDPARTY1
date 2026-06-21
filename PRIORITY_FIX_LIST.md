# ARVIND PARTY - PRIORITY FIX LIST

**Generated:** 2025-06-21  
**Project:** Arvind Party  
**Severity Levels:** Priority 1 (CRITICAL) | Priority 2 (HIGH) | Priority 3 (MEDIUM/LOW)

---

## PRIORITY 1 - CRITICAL ISSUES

### P1.1 Create `backend/server.js`
**Impact:** Backend cannot start. `npm start` and `npm run dev` both fail.  
**File:** `lib/arvind-party-backend/server.js` (MISSING)  
**Action:**
```javascript
// server.js
const app = require('./src/app');
const dotenv = require('dotenv');
dotenv.config();

const PORT = process.env.PORT || 5000;
const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// Socket.io
const socketIO = require('./src/config/socket');
socketIO(server);

// Graceful shutdown
process.on('SIGTERM', () => {
  server.close(() => console.log('Server shut down gracefully'));
});
```

### P1.2 Create `backend/.env`
**Impact:** All environment variables undefined. Database, Firebase, JWT, Razorpay, Twilio all fail.  
**File:** `lib/arvind-party-backend/.env` (MISSING)  
**Action:**
```env
# Server
NODE_ENV=development
PORT=5000

# Database
MONGODB_URI=mongodb://localhost:27017/arvindparty
# OR production: mongodb+srv://user:pass@cluster.mongo.net/arvindparty

# JWT
JWT_SECRET=your_jwt_secret_here_min_32_chars
JWT_EXPIRY=15m
REFRESH_TOKEN_SECRET=your_refresh_secret_here
REFRESH_TOKEN_EXPIRY=7d

# Firebase
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\n...
FIREBASE_CLIENT_EMAIL=your_service_account_email

# Razorpay
RAZORPAY_KEY_ID=your_key_id
RAZORPAY_KEY_SECRET=your_key_secret

# Twilio
TWILIO_ACCOUNT_SID=your_sid
TWILIO_AUTH_TOKEN=your_token
TWILIO_PHONE_NUMBER=+1234567890

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Redis
REDIS_URL=redis://localhost:6379

# CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:8080

# App
APP_NAME=Arvind Party
APP_VERSION=1.0.0
```

### P1.3 Extract Backend from `lib/`
**Impact:** Backend cannot be deployed independently. CI/CD impossible.  
**Action:**
```bash
# Move backend to project root
mv lib/arvind-party-backend backend

# Update package.json scripts
# "start": "node src/server.js",
# "dev": "nodemon src/server.js",

# Update imports if needed
```

### P1.4 Initialize Socket.io in Backend
**Impact:** Real-time chat, notifications, live room updates all broken.  
**File:** `lib/arvind-party-backend/src/app.js`  
**Action:** Add after route mounting:
```javascript
const http = require('http');
const socketIO = require('./config/socket');

const server = http.createServer(app);
socketIO(server); // Initialize Socket.io before routes
```

### P1.5 Initialize Firebase Admin in Backend
**Impact:** FCM push notifications, OTP verification broken.  
**File:** `lib/arvind-party-backend/src/app.js`  
**Action:** Add at top of app.js:
```javascript
const admin = require('./config/firebase-admin');
admin.initializeApp();
```

### P1.6 Verify Flutter API Base URL
**Impact:** All API calls fail if URL is wrong.  
**Files:** `lib/core/services/api_service.dart`, `lib/core/network/dio_client.dart`  
**Action:** Ensure base URL is configurable:
```dart
// Development
static const String baseUrl = 'http://192.168.1.100:5000/api';

// Production
static const String baseUrl = 'https://api.arvindparty.com/api';
```

### P1.7 Remove Duplicate Web Project
**Impact:** Confusion in build/deploy pipelines.  
**Action:** Delete `arvind_party_web/` at project root. Keep only `lib/arvind_party_web/`.

---

## PRIORITY 2 - HIGH PRIORITY ISSUES

### P2.1 Implement JWT Authentication Middleware
**Impact:** All routes are currently public. Security bypass.  
**File:** `lib/arvind-party-backend/src/middlewares/auth.middleware.js` (CREATE)  
**Action:**
```javascript
const jwt = require('jsonwebtoken');
const User = require('../models/user.model');

const authMiddleware = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ message: 'Unauthorized' });
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = await User.findById(decoded.id).select('-password');
    if (!req.user) return res.status(401).json({ message: 'Invalid token' });
    
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid token' });
  }
};

module.exports = authMiddleware;
```

### P2.2 Add Input Validation to All Routes
**Impact:** Injection attacks, XSS, data corruption.  
**Action:** Add `express-validator` to all route files:
```javascript
const { body, param, query } = require('express-validator');

router.post('/login', 
  body('email').isEmail(),
  body('password').isLength({ min: 6 }),
  validateRequest,
  authController.login
);
```

### P2.3 Implement Request Body Sanitization
**Impact:** XSS, injection attacks.  
**Action:** Add sanitization middleware:
```javascript
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');

app.use(mongoSanitize());
app.use(xss());
```

### P2.4 Merge Duplicate Controllers
**Impact:** Conflicting logic, maintenance nightmare.  
**Files:**
- `admin.controller.js` + `adminController.js` → Keep `admin.controller.js`
- `game.controller.js` + `gameController.js` → Keep `gameController.js`
- `pkBattle.controller.js` → Consolidate

### P2.5 Implement Wallet Transaction Atomicity
**Impact:** Double-spend, coin manipulation, financial loss.  
**Action:**
```javascript
const session = await mongoose.startSession();
session.startTransaction();

try {
  // Deduct from sender
  await User.updateOne(
    { _id: senderId },
    { $inc: { coins: -amount } },
    { session }
  );
  
  // Add to receiver
  await User.updateOne(
    { _id: receiverId },
    { $inc: { coins: amount } },
    { session }
  );
  
  // Record transaction with idempotency key
  await Transaction.create([{
    from: senderId,
    to: receiverId,
    amount,
    idempotencyKey: req.idempotencyKey,
    status: 'completed'
  }], { session });
  
  await session.commitTransaction();
} catch (error) {
  await session.abortTransaction();
  throw error;
}
```

### P2.6 Add `.gitignore` Entries for Secrets
**Impact:** Secrets leak to version control.  
**Action:** Ensure `.gitignore` contains:
```
.env
.env.local
.env.*.local
*.pem
*.key
service-account.json
```

### P2.7 Implement JWT Refresh Token Flow
**Impact:** Users logged out frequently, poor UX.  
**Action:**
```javascript
// Issue refresh token on login
const refreshToken = jwt.sign(
  { id: user._id, type: 'refresh' },
  process.env.REFRESH_TOKEN_SECRET,
  { expiresIn: '7d' }
);

// Refresh endpoint
router.post('/refresh', (req, res) => {
  const { refreshToken } = req.body;
  // Verify and issue new access token
});
```

### P2.8 Add API Versioning
**Impact:** Breaking changes affect existing apps.  
**Action:**
```javascript
// Update all routes to /api/v1/
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
// ...
```

### P2.9 Implement Auth Middleware Protection
**Impact:** All routes publicly accessible.  
**Action:** Add `authMiddleware` to protected routes:
```javascript
router.get('/profile', authMiddleware, userController.getProfile);
```

### P2.10 Add MongoDB Indexes
**Impact:** Slow queries, poor performance at scale.  
**Action:**
```javascript
// In models/user.model.js
userSchema.index({ email: 1 });
userSchema.index({ phone: 1 });

// In models/room.model.js
roomSchema.index({ status: 1, createdAt: -1 });
roomSchema.index({ hostId: 1 });
```

---

## PRIORITY 3 - MEDIUM / LOW PRIORITY

### P3.1 Add OpenAPI/Swagger Documentation
**Impact:** No API documentation, hard to integrate.  
**File:** `lib/arvind-party-backend/src/docs/swagger.js` (CREATE)  
**Action:** Install `swagger-jsdoc` and `swagger-ui-express`. Add JSDoc comments to all routes.

### P3.2 Add Unit Tests for Auth & Wallet
**Impact:** Regression risk in critical flows.  
**Action:**
```javascript
// Install Jest + Supertest
npm install --save-dev jest supertest

// Create tests/auth.test.js
describe('POST /api/v1/auth/login', () => {
  it('should return token for valid credentials', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ email: 'test@test.com', password: 'password' });
    expect(res.statusCode).toEqual(200);
    expect(res.body.token).toBeDefined();
  });
});
```

### P3.3 Add Error Boundary in Flutter
**Impact:** App crashes without recovery.  
**File:** `lib/core/error/error_boundary.dart` (CREATE)  
**Action:**
```dart
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  var hasError = false;
  @override
  Widget build(BuildContext context) {
    if (hasError) return ErrorScreen(onRetry: () => setState(() => hasError = false));
    return widget.child;
  }
}
```

### P3.4 Add Offline Detection & Retry
**Impact:** Poor UX when network is unstable.  
**File:** `lib/core/utils/network_manager.dart`  
**Action:**
```dart
class NetworkManager extends GetxController {
  final Connectivity _connectivity = Connectivity();
  
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```

### P3.5 Add crash reporting (Firebase Crashlytics)
**Impact:** Hard to debug production crashes.  
**Action:**
```yaml
# pubspec.yaml
dependencies:
  firebase_crashlytics: ^4.0.0
```

### P3.6 Add lazy loading to GetX Bindings
**Impact:** Slow app startup.  
**Action:**
```dart
// Replace Get.put with Get.lazyPut for non-critical dependencies
Get.lazyPut(() => ShopController(), fenix: true);
Get.lazyPut(() => RankingController(), fenix: true);
```

### P3.7 Add Local Notifications Fallback
**Impact:** Users miss notifications when FCM fails.  
**Action:** Add `flutter_local_notifications` package.

### P3.8 Add Image Cropper for Avatar Upload
**Impact:** Poor avatar quality.  
**Action:** Add `image_cropper` package.

### P3.9 Add Database Backup Strategy
**Impact:** Data loss risk.  
**Action:** Setup automated MongoDB backups using `mongodump` cron job or MongoDB Atlas backups.

### P3.10 Add Redis Caching for Leaderboards
**Impact:** Slow leaderboard queries.  
**Action:**
```javascript
const redis = require('redis');
const client = redis.createClient(process.env.REDIS_URL);

// Cache leaderboard
app.get('/api/v1/rankings/leaderboard', async (req, res) => {
  const cached = await client.get('leaderboard:global');
  if (cached) return res.json(JSON.parse(cached));
  
  const leaderboard = await Leaderboard.find().limit(100);
  await client.setEx('leaderboard:global', 300, JSON.stringify(leaderboard));
  return res.json(leaderboard);
});
```

---

## PHASED IMPLEMENTATION PLAN

### Phase 1 (Week 1): Foundation
- [x] Analyze project (COMPLETE)
- [ ] P1.1 Create `backend/server.js`
- [ ] P1.2 Create `backend/.env`
- [ ] P1.3 Extract backend from `lib/`
- [ ] P1.4 Initialize Socket.io
- [ ] P1.5 Initialize Firebase Admin
- [ ] P1.6 Verify Flutter API base URL
- [ ] P1.7 Remove duplicate web project

### Phase 2 (Week 2-3): Security & Connectivity
- [ ] P2.1 JWT auth middleware
- [ ] P2.2 Input validation all routes
- [ ] P2.3 Body sanitization
- [ ] P2.4 Merge duplicate controllers
- [ ] P2.5 Wallet atomic transactions
- [ ] P2.6 .gitignore secrets
- [ ] P2.7 JWT refresh flow
- [ ] P2.8 API versioning
- [ ] P2.9 Auth middleware protection
- [ ] P2.10 MongoDB indexes

### Phase 3 (Week 4-6): Quality & Reliability
- [ ] P3.1 OpenAPI docs
- [ ] P3.2 Unit tests
- [ ] P3.3 Flutter error boundary
- [ ] P3.4 Offline detection
- [ ] P3.5 Crashlytics
- [ ] P3.6 Lazy loading
- [ ] P3.7 Local notifications
- [ ] P3.8 Image cropper
- [ ] P3.9 Database backup
- [ ] P3.10 Redis caching

---

## ESTIMATED TIMELINE

| Phase | Duration | Critical Path Items |
|-------|----------|---------------------|
| Phase 1 | 3-5 days | server.js, .env, Socket.io, Firebase Admin |
| Phase 2 | 2-3 weeks | Auth middleware, wallet security, validation |
| Phase 3 | 2-3 weeks | Tests, docs, caching, monitoring |
| **Total** | **4-6 weeks** | To production-ready backend |

---

## SUCCESS CRITERIA

- [ ] `npm start` in `backend/` starts server without errors
- [ ] Flutter app connects to backend and receives responses
- [ ] All authenticated routes return 401 without token
- [ ] All authenticated routes return 200 with valid token
- [ ] Wallet transactions are atomic (no double-spend possible)
- [ ] Socket.io connects and handles chat events
- [ ] FCM receives push notifications
- [ ] All 30+ API routes documented in Swagger
- [ ] Test coverage > 60% for auth and wallet modules
- [ ] No secrets in version control