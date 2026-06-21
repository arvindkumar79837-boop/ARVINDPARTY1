import os
import re

# Files to fix
files = [
    'lib/features/auth/presentation/views/email_login_screen.dart',
    'lib/features/auth/presentation/views/social_login_screen.dart',
    'lib/features/auth/presentation/views/device_binding_screen.dart',
    'lib/features/auth/presentation/views/multi_device_control_screen.dart',
    'lib/features/auth/presentation/views/password_reset_screen.dart',
    'lib/features/auth/presentation/views/session_management_screen.dart',
    'lib/features/auth/presentation/controllers/device_binding_controller.dart',
    'lib/features/auth/presentation/controllers/login_controller.dart',
    'lib/features/family/presentation/views/family_tasks_screen.dart',
    'lib/features/family/presentation/views/family_wallet_screen.dart',
    'lib/features/family/presentation/views/family_wars_screen.dart',
    'lib/features/room/presentation/views/room_lock_screen.dart',
    'lib/features/admin/presentation/views/admin_dashboard_screen.dart',
    'lib/features/admin/presentation/views/broadcast_screen.dart',
    'lib/features/admin/presentation/views/staff_management_screen.dart',
    'lib/features/agency/presentation/views/agency_leaderboard_screen.dart',
    'lib/features/agency/presentation/views/agency_salary_screen.dart',
    'lib/features/games/presentation/views/game_leaderboard_screen.dart',
    'lib/features/games/presentation/views/game_reward_store_screen.dart',
    'lib/features/games/presentation/views/game_screen.dart',
    'lib/features/inventory/presentation/views/inventory_screen.dart',
    'lib/features/level/presentation/views/level_screen.dart',
    'lib/features/media/presentation/views/media_player_screen.dart',
    'lib/features/media/presentation/views/playlist_screen.dart',
    'lib/features/media/presentation/views/sound_effects_panel.dart',
    'lib/features/media/presentation/views/youtube_screen.dart',
    'lib/features/wallet/presentation/controllers/wallet_controller.dart',
    'lib/features/auth/presentation/views/account_security_screen.dart',
    'lib/features/room/presentation/views/host_controls_screen.dart',
]

for f in files:
    path = os.path.join('d:/Alarms/arvind_party', f)
    if not os.path.exists(path):
        print(f"SKIP (not found): {f}")
        continue
    with open(path, 'r', encoding='utf-8') as fh:
        content = fh.read()
    original = content
    # Replace withOpacity(value) with withValues(alpha: value)
    content = re.sub(r'withOpacity\(([^)]+)\)', r'withValues(alpha: \1)', content)
    if content != original:
        with open(path, 'w', encoding='utf-8') as fh:
            fh.write(content)
        print(f"FIXED: {f}")
    else:
        print(f"NO CHANGES: {f}")