import os
path = r'Arvind  app analyse report.md'
text = '''
### 1.4 Models Inventory

| Model File | Key Classes |
|---|---|
| `auth_model.dart` | `User`, `AuthResponse` |
| `chat_model.dart` | `MessageModel`, `ChatModel` |
| `room_model.dart` / `room_models.dart` | `RoomModel`, `SeatData`, `RoomMemberModel`, `PKChallenge`, `RoomTask` |
| `family_model.dart` + 5 others | `FamilyData`, `FamilyTask`, `FamilyLeaderboard`, etc. |
| `gift_model.dart` | `GiftModel`, `GiftEventModel`, `GiftHistoryModel` |
| `wallet_model.dart` | `WalletBalance`, `FamilyWalletData`, `AgencyWalletData`, `TransactionModel`, `RechargePackage` |
| `private_message_model.dart` | Private message DTOs |
| `power_matrix_model.dart` | Power matrix entities |
| `shared/models/*` | `BadgeModel`, `FrameModel`, `SessionModel`, `WithdrawalMethodModel`, `DeviceModel` |

---

## 2. Code & Package Health — Errors, Conflicts, Deprecations

### 2.1 Confirmed Active Issues

| # | Issue | File(s) | Detail |
|---|---|---|---|
| **E1** | SettingsController wrong base class | `settings_controller.dart` | Extends `GetxService` but manages UI state. Should extend `GetxController`. |
| **E2** | Hardcoded credentials / secrets | `env_config.dart`, `payment_service.dart` | Dev IP `192.168.1.100:5000`, LiveKit URL `wss://YOUR_LIVEKIT_DOMAIN`, placeholder Razorpay key. |
| **E3** | Secure storage declared but unused | `pubspec.yaml`, codebase | `flutter_secure_storage` is declared but `SharedPreferences` / `GetStorage` are used for tokens. |
| **E4** | Duplicate gift modules | `features/gift/` and `features/gifts/` | Risk of import ambiguity. |
| **E5** | Missing screen controller binding mismatch | `room_binding.dart` | Binds `RoomController` by default; some screens use `LiveRoomController` directly. |
| **E6** | FamilyController uses `print()` | `family_controller.dart` | Should use `debugPrint()`. |
| **E7** | Silent catch blocks | `events_controller.dart`, `level_controller.dart`, others | Many `catch (e) { /* silently fail */ }` patterns. |
| **E8** | Mock / hardcoded data | `admin_controller.dart`, `level_controller.dart`, `inventory_controller.dart` | Hardcoded mock data instead of API. |
| **E9** | Inconsistent API access patterns | Multiple repos | Some use `_apiService.get()`, others use `_apiService.dio.get()` directly. |
| **E10** | No SSL pinning / network security config | `api_service.dart`, Android manifest | Dio client lacks certificate pinning. |
| **E11** | `messages.dart` oversized | `core/localization/messages.dart` | ~1051 lines. Should be split per language. |
| **E12** | Backup / debug artifacts in repo | `lib/core/socket/socket_service.dart.bak`, `lib/main.dart.bak`, `socket_service_debug.txt`, `fix_socket.ps1` | Stale files committed under `lib/`. |

### 2.2 Type Safety & Mismatch Risks

| # | Issue | File(s) | Detail |
|---|---|---|---|
| **T1** | Observable type inconsistency | Various | `var isLoading = false.obs` is `RxBool`, but some controllers treat it as plain `bool` in setters. |
| **T2** | Nullable token handling | `auth_controller.dart` | Mixes `Rxn<String>` and non-nullable `String` domains. |
| **T3** | `dynamic` return types from API | `api_service.dart:77-121` | Every HTTP method returns `Future<dynamic>`. |
| **T4** | Socket event payload casts | Multiple controllers | Raw `as Map<String, dynamic>` after `emit` responses. |
| **T5** | `DateTime.parse` without try-catch | `auth_model.dart` | Can throw on malformed fallback. |
| **T6** | Unused extension method | `auth_model.dart` | `_StringSlice` is private and never imported. |

### 2.3 Deprecated / Legacy API Status

| # | Deprecated Pattern | File | Detail |
|---|---|---|---|
| **D1** | `Colors.white.withAlpha(12)` vs `.withValues(alpha:)` | `otp_screen.dart` | Mixed usage — some legacy `withAlpha()` may remain. |
| **D2** | `socket.on('event', callback)` without symmetric cleanup | `live_room_controller.dart` | Adds listeners but does not always unsubscribe in `onClose()`. |
| **D3** | `print()` vs `debugPrint()` | `family_controller.dart` | Violates Flutter lint rules. |
| **D4** | `GetBuilder` mixed with `Obx` | `app_pages.dart` | Inconsistent patterns across aging codebase. |
'''
with open(path, 'a', encoding='utf-8') as f:
    f.write(text)
