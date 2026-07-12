import os
path = r'Arvind  app analyse report.md'
text = '''
---

## 3. Feature Roadmap Audit

### 3.1 High-Priority Missing Features

| Feature | Priority | Notes |
|---|---|---|
| **Seat Management (backend-less)** | High | Frontend seat UI works, but no backend verification. |
| **Room Roles (Agent/Staff)** | High | Enum exists, but no role assignment API or admin CRUD. |
| **Firebase Phone OTP** | High | Firebase initialized, but auth flow uses Node.js OTP. |
| **Real-time Packages** | High | Packages installed, but FCM push and real-time sync are partial. |
| **Deep Linking** | High | No package or dynamic link config. |
| **Wallet Withdrawal to Bank** | High | Controller present, backend integration pending. |
'''
with open(path, 'a', encoding='utf-8') as f:
    f.write(text)
