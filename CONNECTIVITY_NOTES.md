# CONNECTIVITY_NOTES.md

## Abhi Kya Use Ho Raha Hai

**Testing Server (single server, HTTP):**
```
http://222.167.207.78:5000
```

Ye URL teen jagah se control hota hai:
- `lib/core/constants/env_config.dart` → `devBaseUrl`, `stagingBaseUrl`, `prodBaseUrl` (all three point here)
- `android/app/src/main/res/xml/network_security_config.xml` → sirf is IP ke liye HTTP allowed
- `ios/Runner/Info.plist` → sirf is IP ke liye HTTP allowed

---

## Domain Milne Ke Baad — Exactly Kaunsi Files/Lines Change Karni Hain

### Step 1: `lib/core/constants/env_config.dart` (line ~31)
```dart
// BEFORE (abhi):
static const String prodBaseUrl = 'http://222.167.207.78:5000';

// AFTER (domain milne ke baad):
static const String prodBaseUrl = 'https://yourdomain.com';
```

### Step 2: `android/app/src/main/res/xml/network_security_config.xml`
Pura `<domain-config cleartextTrafficPermitted="true">` section hata do ya delete karo.
Default `<base-config cleartextTrafficPermitted="false">` already HTTPS-only enforce karega.

### Step 3: `ios/Runner/Info.plist` → `NSExceptionDomains` section
Ye pura section hata do:
```xml
<key>NSExceptionDomains</key>
<dict>
    <key>222.167.207.78</key>
    <dict>
        <key>NSExceptionAllowsInsecureHTTPLoads</key>
        <true/>
        <key>NSExceptionRequiresForwardSecrecy</key>
        <false/>
    </dict>
</dict>
```
`NSAllowsArbitraryLoads` ko `false` rehne do (ya section pura hata do).

---

## Architecture Summary

```
EnvConfig.baseUrl (single source of truth)
    ├── apiBaseUrl  → "$baseUrl/api"   (ApiService, Dio)
    ├── socketUrl   → baseUrl          (Socket.IO)
    └── plainApiBaseUrl → "$baseUrl/api" (repositories)
```

Ek jagah change karo → sab jagah apply hota hai.
