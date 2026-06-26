# ARVIND PARTY Features Report

## API Connection Audit
| Mobile Endpoint Constant | Backend Prefix | Source Type | Mobile Connected? | Backend Exists? | Working? | Note |
|---|---|---|---|---|---|---|
| `/admin` | `/api/admin` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/agency` | `/api/agency` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/auth` | `/api/auth` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/blind-date/match` | `/api/blind-date` | Static constant | Yes | No | No | No matching mounted prefix in src/app.js |
| `/blind-date/stop` | `/api/blind-date` | Static constant | Yes | No | No | No matching mounted prefix in src/app.js |
| `/chat` | `/api/chat` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/coin-orders` | `/api/coin-orders` | Static constant | Yes | No | No | No matching mounted prefix in src/app.js |
| `/creator` | `/api/creator` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/events` | `/api/events` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/families` | `/api/families` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/games` | `/api/games` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/gifts` | `/api/gifts` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/inventory` | `/api/inventory` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/level` | `/api/level` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/lucky-draw/rewards` | `/api/lucky-draw` | Static constant | Yes | No | No | No matching mounted prefix in src/app.js |
| `/lucky-draw/spin` | `/api/lucky-draw` | Static constant | Yes | No | No | No matching mounted prefix in src/app.js |
| `/moderation` | `/api/moderation` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/moments` | `/api/moments` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/notifications` | `/api/notifications` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/pk-battles` | `/api/pk-battles` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/rankings` | `/api/rankings` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/referral` | `/api/referral` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/rewards` | `/api/rewards` | Static constant | Yes | No | No | No matching mounted prefix in src/app.js |
| `/rooms` | `/api/rooms` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/security` | `/api/security` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/shop` | `/api/shop` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/staff` | `/api/staff` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/support` | `/api/support` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/targets` | `/api/targets` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/treasury` | `/api/treasury` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/users` | `/api/users` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/vip` | `/api/vip` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |
| `/wallet` | `/api/wallet` | Static constant | Yes | Yes | Likely | Mounted backend prefix found |

## Connectivity Summary
- Mobile to backend: statically connected through `ApiConstants` and env config.
- Web to backend: statically connected through `core/services/api_service.dart` and web env config.
- Backend to MongoDB: boot path present.
- Backend to Redis: optional with fallback.
- Backend sockets: room, chat, seat, gift, pk battle, family, and agency handlers exist.

## Feature Completion Matrix
| Platform | Estimated Completion |
|---|---:|
| Mobile app | 64% |
| Web panel | 62% |
| Backend | 85% |
| Overall | 70% |
