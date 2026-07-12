import os, re

files = [
    'lib/features/admin/presentation/repositories/admin_repository.dart',
    'lib/features/agency/presentation/repositories/agency_repository.dart',
    'lib/features/blind_date/presentation/repositories/blind_date_repository.dart',
    'lib/features/events/presentation/repositories/events_repository.dart',
    'lib/features/games/presentation/repositories/games_repository.dart',
    'lib/features/moments/presentation/repositories/moments_repository.dart',
    'lib/features/notifications/presentation/repositories/notifications_repository.dart',
    'lib/features/pk_battle/presentation/repositories/pk_battle_repository.dart',
    'lib/features/ranking/presentation/repositories/ranking_repository.dart',
    'lib/features/shop/presentation/repositories/shop_repository.dart',
]

for path in files:
    if not os.path.exists(path):
        continue
    
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "import 'package:dio/dio.dart';" in content:
        continue
    
    # Check if file still uses Options or Dio types
    if not re.search(r'\bOptions\b|\bDioException\b|\bDio\b', content):
        continue
    
    # Insert dio import after get import or at the top
    lines = content.split('\n')
    insert_idx = 0
    for i, line in enumerate(lines):
        if line.startswith('import '):
            insert_idx = i + 1
    lines.insert(insert_idx, "import 'package:dio/dio.dart';")
    content = '\n'.join(lines)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Restored dio import: {path}")

print("Done")
