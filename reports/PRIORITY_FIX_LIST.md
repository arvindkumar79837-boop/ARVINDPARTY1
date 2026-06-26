# PRIORITY FIX LIST

## Priority 1 Critical
- Lock down `arvind_party_web/lib/core/constants/env_config.dart` and remove placeholder production blockers.
- Move mobile `lib/core/constants/env_config.dart` away from hardcoded development defaults.
- Add distributed rate limiting and verify JWT / socket authorization coverage.
- Add CI/CD and release validation before any production deployment.
- Review wallet, withdrawal, gift, and ranking write paths for transaction safety.

## Priority 2 Important
- Add integration tests for auth, rooms, family, wallet, ranking, and admin APIs.
- Add production monitoring, structured logging, and alerting.
- Add deployment manifests and backup automation.
- Verify all third-party services: Firebase, Agora, Razorpay, Twilio, Redis.
- Audit route-to-controller coverage for duplicate or stale endpoints.

## Priority 3 Improvements
- Add API documentation and endpoint ownership notes.
- Reduce likely stale analysis artifacts from the repo root.
- Add explicit feature flags and environment tiers for mobile and web.
- Add dead-code cleanup passes for placeholder screens and backup utilities.
