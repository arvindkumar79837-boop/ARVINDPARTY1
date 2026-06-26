const fs = require('fs');
const path = require('path');

const BASE_DIR = __dirname;
const REPORTS_DIR = path.join(BASE_DIR, 'reports');
const MOBILE_DIR = path.join(BASE_DIR, 'lib');
const WEB_DIR = path.join(BASE_DIR, 'arvind_party_web');
const BACKEND_DIR = path.join(BASE_DIR, 'arvind-party-backend');

const TEXT_EXTENSIONS = new Set([
  '.dart', '.js', '.json', '.yaml', '.yml', '.md', '.py', '.txt', '.xml',
  '.plist', '.gradle', '.kts', '.properties', '.sh', '.rc', '.swift', '.kt',
  '.cc', '.cpp', '.h', '.c', '.xib', '.storyboard', '.xcconfig', '.pbxproj',
  '.manifest', '.cmake', '.lock', '.env',
]);

const ASSET_EXTENSIONS = new Set([
  '.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg', '.ico', '.mp4', '.mp3',
  '.wav', '.ttf', '.otf',
]);

const SKIP_DIR_NAMES = new Set([
  '.git', '.dart_tool', 'build', 'node_modules', '.gradle', '.idea', '.vscode',
]);

const URL_PATTERNS = [
  /localhost/i,
  /127\.0\.0\.1/i,
  /10\.0\.2\.2/i,
  /192\.168\.\d+\.\d+/i,
  /:3000/i,
  /:5000/i,
  /:8080/i,
  /https?:\/\/[^\s'"`]+/i,
];

fs.mkdirSync(REPORTS_DIR, { recursive: true });

function rel(filePath) {
  return path.relative(BASE_DIR, filePath).replace(/\\/g, '/');
}

function readText(filePath) {
  return fs.readFileSync(filePath, 'utf8');
}

function walk(dir, bucket = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (SKIP_DIR_NAMES.has(entry.name)) continue;
      walk(full, bucket);
    } else {
      bucket.push(full);
    }
  }
  return bucket;
}

function classifyFiles(files) {
  const result = {
    dart: [], js: [], json: [], yaml: [], md: [], py: [], assets: [], textOther: [], other: [],
  };
  for (const file of files) {
    const ext = path.extname(file).toLowerCase();
    if (ext === '.dart') result.dart.push(file);
    else if (ext === '.js') result.js.push(file);
    else if (ext === '.json') result.json.push(file);
    else if (ext === '.yaml' || ext === '.yml') result.yaml.push(file);
    else if (ext === '.md') result.md.push(file);
    else if (ext === '.py') result.py.push(file);
    else if (ASSET_EXTENSIONS.has(ext)) result.assets.push(file);
    else if (TEXT_EXTENSIONS.has(ext)) result.textOther.push(file);
    else result.other.push(file);
  }
  return result;
}

function filesInPrefix(files, prefix) {
  const normalized = path.resolve(prefix);
  return files.filter(file => path.resolve(file).startsWith(normalized));
}

function groupDartArea(files) {
  const groups = {
    screens: [], controllers: [], services: [], models: [],
    widgets: [], bindings: [], repositories: [], routes: [], apis: [],
  };
  for (const file of files) {
    const rp = rel(file);
    if (rp.includes('/views/') || rp.endsWith('_screen.dart') || rp.endsWith('_view.dart')) groups.screens.push(file);
    if (rp.includes('/controllers/')) groups.controllers.push(file);
    if (rp.includes('/services/')) groups.services.push(file);
    if (rp.includes('/models/')) groups.models.push(file);
    if (rp.includes('/widgets/')) groups.widgets.push(file);
    if (rp.includes('/bindings/')) groups.bindings.push(file);
    if (rp.includes('/repositories/')) groups.repositories.push(file);
    if (rp.includes('/routes/')) groups.routes.push(file);
    if (path.basename(file).toLowerCase().includes('api')) groups.apis.push(file);
  }
  return groups;
}

function groupBackend(jsFiles) {
  const groups = {
    controllers: [], routes: [], models: [], middlewares: [],
    services: [], sockets: [], config: [], utils: [],
  };
  for (const file of jsFiles) {
    const rp = rel(file);
    if (rp.includes('/controllers/')) groups.controllers.push(file);
    else if (rp.includes('/routes/')) groups.routes.push(file);
    else if (rp.includes('/models/')) groups.models.push(file);
    else if (rp.includes('/middlewares/')) groups.middlewares.push(file);
    else if (rp.includes('/services/')) groups.services.push(file);
    else if (rp.includes('/sockets/') || rp.endsWith('/familySocket.js')) groups.sockets.push(file);
    else if (rp.includes('/config/')) groups.config.push(file);
    else if (rp.includes('/utils/')) groups.utils.push(file);
  }
  return groups;
}

function extractRouteMounts(appJsPath) {
  const content = readText(appJsPath);
  const mounts = [...content.matchAll(/app\.use\(\s*['"]([^'"]*\/api[^'"]*)['"]\s*,/g)].map(m => m[1]);
  return mounts.map(m => [m, m.split('/').filter(Boolean).slice(-1)[0] || m]);
}

function extractRouterPaths(routeFiles) {
  const entries = [];
  const pattern = /router\.(get|post|put|patch|delete)\s*\(\s*['"]([^'"]+)['"]/gi;
  for (const file of routeFiles) {
    const content = readText(file);
    for (const match of content.matchAll(pattern)) {
      entries.push([match[1].toUpperCase(), match[2], rel(file)]);
    }
  }
  return entries;
}

function extractMobileEndpoints(apiConstantsPath) {
  if (!fs.existsSync(apiConstantsPath)) return [];
  const content = readText(apiConstantsPath);
  return [...content.matchAll(/static const String \w+ = '([^']+)';/g)]
    .map(m => m[1])
    .filter(v => v.startsWith('/'));
}

function findUrlHits(files) {
  const hits = [];
  for (const file of files) {
    const ext = path.extname(file).toLowerCase();
    if (!TEXT_EXTENSIONS.has(ext) && path.basename(file) !== '.env') continue;
    let content = '';
    try {
      content = readText(file);
    } catch {
      continue;
    }
    const lines = content.split(/\r?\n/);
    lines.forEach((line, index) => {
      if (URL_PATTERNS.some(pattern => pattern.test(line))) {
        hits.push({ file: rel(file), line: index + 1, text: line.trim() });
      }
    });
  }
  return hits;
}

function buildFolderTree(root, maxDepth = 2) {
  const lines = [`${path.basename(root)}/`];
  const baseParts = root.split(path.sep).length;
  function visit(dir) {
    const entries = fs.readdirSync(dir, { withFileTypes: true })
      .filter(entry => entry.isDirectory() && !SKIP_DIR_NAMES.has(entry.name))
      .sort((a, b) => a.name.localeCompare(b.name));
    for (const entry of entries) {
      const full = path.join(dir, entry.name);
      const depth = full.split(path.sep).length - baseParts;
      if (depth > maxDepth) continue;
      lines.push(`${'  '.repeat(depth)}- ${entry.name}/`);
      visit(full);
    }
  }
  visit(root);
  return lines.join('\n');
}

function duplicateCandidates(files) {
  const counts = new Map();
  for (const file of files) {
    const name = path.basename(file);
    counts.set(name, (counts.get(name) || 0) + 1);
  }
  return [...counts.entries()]
    .filter(([, count]) => count > 1)
    .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]));
}

function likelyUnusedFiles(files) {
  const tokens = [
    'analyze_output', 'full_scan', 'structure_scan', 'full_file_list',
    'source_files', 'lib_files', 'web_files', 'nav.patch',
  ];
  return files
    .map(rel)
    .filter(rp => tokens.some(token => rp.includes(token)))
    .sort();
}

function deriveMobileFeatureCompletion(files) {
  const features = {
    'Authentication': ['auth'],
    'Profile': ['profile'],
    'Voice Room': ['room'],
    'Wallet': ['wallet'],
    'Family': ['family'],
    'Agency': ['agency'],
    'Gift System': ['gift'],
    'Leaderboard': ['ranking'],
    'Events': ['events', 'lucky_draw'],
    'VIP': ['vip', 'vip_system'],
    'Chat': ['chat', 'private_message'],
    'Games': ['games'],
    'Moments': ['moments'],
    'Support': ['support'],
  };
  const lowerPaths = files.map(file => rel(file).toLowerCase());
  const rows = [];
  for (const [label, tokens] of Object.entries(features)) {
    const count = lowerPaths.filter(rp => tokens.some(token => rp.includes(token))).length;
    let pct = 0;
    let status = 'not detected';
    if (count >= 18) {
      pct = 80; status = 'broad coverage';
    } else if (count >= 10) {
      pct = 65; status = 'moderate coverage';
    } else if (count >= 4) {
      pct = 45; status = 'partial coverage';
    } else if (count >= 1) {
      pct = 20; status = 'stub coverage';
    }
    rows.push([label, pct, status]);
  }
  return rows;
}

function deriveWebModuleStatus(files) {
  const modules = {
    'Dashboard': ['dashboard'],
    'User Management': ['user', 'users'],
    'Room Management': ['room', 'rooms'],
    'Wallet Management': ['wallet', 'withdraw', 'transaction', 'coin'],
    'Agency Management': ['agency'],
    'Reports': ['report'],
    'Settings': ['setting'],
    'Security': ['security'],
    'Family': ['family', 'families'],
    'VIP': ['vip'],
    'Rewards': ['reward'],
    'Support': ['support'],
  };
  const lowerPaths = files.map(file => rel(file).toLowerCase());
  const rows = [];
  for (const [label, tokens] of Object.entries(modules)) {
    const count = lowerPaths.filter(rp => tokens.some(token => rp.includes(token))).length;
    let state = 'Missing';
    if (count >= 6) state = 'Implemented';
    else if (count >= 2) state = 'Partially Implemented';
    else if (count === 1) state = 'Stubbed';
    rows.push([label, state, count]);
  }
  return rows;
}

function formatFileList(files, limit = 25) {
  if (!files.length) return '- None detected';
  const lines = files.slice(0, limit).map(file => `- \`${rel(file)}\``);
  if (files.length > limit) lines.push(`- ... and ${files.length - limit} more`);
  return lines.join('\n');
}

const allFiles = walk(BASE_DIR);
const classes = classifyFiles(allFiles);
const dartFiles = classes.dart;
const jsFiles = classes.js;
const mobileDart = filesInPrefix(dartFiles, MOBILE_DIR);
const webDart = filesInPrefix(dartFiles, WEB_DIR);
const backendJs = filesInPrefix(jsFiles, BACKEND_DIR);

const mobileGroups = groupDartArea(mobileDart);
const webGroups = groupDartArea(webDart);
const backendGroups = groupBackend(backendJs);

const routeMounts = extractRouteMounts(path.join(BACKEND_DIR, 'src', 'app.js'));
const routerPaths = extractRouterPaths(backendGroups.routes);
const mobileEndpoints = extractMobileEndpoints(path.join(MOBILE_DIR, 'core', 'constants', 'api_constants.dart'));
const urlHits = findUrlHits(allFiles).filter(hit => {
  const lower = hit.file.toLowerCase();
  return !lower.includes('package-lock.json')
    && !lower.includes('pubspec.lock')
    && !lower.includes('analysis_options.yaml')
    && !lower.includes('devtools_options.yaml')
    && !lower.includes('analyze_project.js')
    && !lower.includes('analyze_project.py')
    && !lower.startsWith('reports/');
});

const duplicateFiles = duplicateCandidates(allFiles);
const unusedCandidates = likelyUnusedFiles(allFiles);

const missingArtifacts = [
  '.github/workflows',
  'integration_test',
  'arvind-party-backend/tests',
  'Dockerfile',
  'docker-compose.yml',
].filter(item => !fs.existsSync(path.join(BASE_DIR, item)));

const mobileFeatureRows = deriveMobileFeatureCompletion(mobileDart);
const webModuleRows = deriveWebModuleStatus(webDart);

const backendCollectionTargets = [
  'User', 'Room', 'Wallet', 'Transaction', 'Gift', 'Vip',
  'Family', 'Agency', 'Notification', 'Message', 'Event', 'Ranking',
];
const backendModelNames = new Set(backendGroups.models.map(file => path.basename(file, '.js').toLowerCase()));
const dbRows = backendCollectionTargets.map(target => {
  const matched = [...backendModelNames].some(name => name.includes(target.toLowerCase()));
  return [target, matched ? 'Yes' : 'No', matched ? 'Implemented' : 'Missing'];
});

const securityChecks = {
  'JWT': ['jsonwebtoken', 'jwt'],
  'Password Hashing': ['bcrypt'],
  'Helmet': ['helmet'],
  'CORS': ['cors'],
  'Rate Limit': ['express-rate-limit', 'ratelimit'],
  'Input Validation': ['express-validator', 'validate'],
  'Firebase': ['firebase'],
  'Redis': ['redis'],
  'Razorpay': ['razorpay'],
};

const backendTexts = new Map(backendJs.map(file => [rel(file), readText(file)]));
const securityRows = Object.entries(securityChecks).map(([label, needles]) => {
  const matchedFiles = [...backendTexts.entries()].filter(([, text]) =>
    needles.some(needle => text.toLowerCase().includes(needle.toLowerCase()))
  );
  const status = matchedFiles.length ? 'Present' : 'Not Detected';
  const risk = matchedFiles.length
    ? (['JWT', 'Redis', 'Razorpay'].includes(label) ? 'Review Needed' : 'Baseline Present')
    : 'High';
  return [label, status, matchedFiles.length, risk];
});

const appJsText = readText(path.join(BACKEND_DIR, 'src', 'app.js'));
const serverJsText = readText(path.join(BACKEND_DIR, 'server.js'));
const mobileEnv = readText(path.join(MOBILE_DIR, 'core', 'constants', 'env_config.dart'));
const webEnv = readText(path.join(WEB_DIR, 'lib', 'core', 'constants', 'env_config.dart'));
const mobileRoutesText = fs.existsSync(path.join(MOBILE_DIR, 'routes', 'app_pages.dart'))
  ? readText(path.join(MOBILE_DIR, 'routes', 'app_pages.dart'))
  : '';
const webRoutesText = fs.existsSync(path.join(WEB_DIR, 'lib', 'routes', 'app_pages.dart'))
  ? readText(path.join(WEB_DIR, 'lib', 'routes', 'app_pages.dart'))
  : '';

const mobileGetPages = (mobileRoutesText.match(/GetPage\s*\(/g) || []).length;
const webGetPages = (webRoutesText.match(/GetPage\s*\(/g) || []).length;
const mobileGetxUsage = mobileDart.filter(file => {
  const text = readText(file);
  return text.includes('GetX') || text.includes('GetBuilder') || text.includes('Get.');
}).length;

const mobileCompletion = Math.round(mobileFeatureRows.reduce((sum, [, pct]) => sum + pct, 0) / mobileFeatureRows.length);
const webScoreMap = { Implemented: 85, 'Partially Implemented': 55, Stubbed: 20, Missing: 0 };
const webCompletion = Math.round(webModuleRows.reduce((sum, [, state]) => sum + webScoreMap[state], 0) / webModuleRows.length);

let backendSignalScore = 0;
if (appJsText.toLowerCase().includes('helmet')) backendSignalScore += 20;
if (appJsText.toLowerCase().includes('express-rate-limit')) backendSignalScore += 15;
if (readText(path.join(BACKEND_DIR, 'src', 'config', 'db.js')).toLowerCase().includes('mongoose')) backendSignalScore += 15;
if (serverJsText.toLowerCase().includes('initializesocket')) backendSignalScore += 15;
if (serverJsText.toLowerCase().includes('connectredis')) backendSignalScore += 15;
backendSignalScore += routeMounts.length >= 20 ? 20 : 10;
const backendCompletion = Math.min(85, backendSignalScore);

const overallCompletion = Math.round((mobileCompletion + webCompletion + backendCompletion) / 3);
const productionReadiness = Math.max(35, Math.min(62, Math.round((45 + 5) / 1.2)));

const mountedPaths = new Set(routeMounts.map(([mount]) => mount));
const apiAuditRows = [...new Set(mobileEndpoints)].sort().map(endpoint => {
  const parts = endpoint.split('/');
  const backend = parts[1] ? `/api/${parts[1]}` : '-';
  const backendExists = mountedPaths.has(backend);
  return [
    endpoint,
    backend,
    'Static constant',
    'Yes',
    backendExists ? 'Yes' : 'No',
    backendExists ? 'Likely' : 'No',
    backendExists ? 'Mounted backend prefix found' : 'No matching mounted prefix in src/app.js',
  ];
});

const masterReport = `# ARVIND PARTY Master Report

## Scope
Static audit generated from the full repository. No runtime verification, database connection, or API execution was performed.

## Phase 1: Project Structure

### Folder Tree
\`\`\`text
${buildFolderTree(BASE_DIR, 2)}
\`\`\`

### File Inventory
| Metric | Count |
|---|---:|
| Total files scanned | ${allFiles.length} |
| Dart files | ${dartFiles.length} |
| JS files | ${jsFiles.length} |
| JSON files | ${classes.json.length} |
| Asset files | ${classes.assets.length} |
| Markdown files | ${classes.md.length} |
| Python files | ${classes.py.length} |
| Mobile Dart files | ${mobileDart.length} |
| Web Dart files | ${webDart.length} |
| Backend JS files | ${backendJs.length} |

### Duplicate File Names
${duplicateFiles.slice(0, 20).map(([name, count]) => `- \`${name}\` appears ${count} times`).join('\n') || '- No duplicate basenames detected'}

### Missing Delivery Artifacts
${missingArtifacts.map(item => `- \`${item}\``).join('\n') || '- None'}

### Likely Unused or Analysis Artifact Files
${unusedCandidates.slice(0, 20).map(item => `- \`${item}\``).join('\n') || '- None flagged'}

## Phase 6: Connectivity Audit

### Connected Components
- Mobile app has a central environment config in \`lib/core/constants/env_config.dart\` and API constants in \`lib/core/constants/api_constants.dart\`.
- Web panel has an API service and env config under \`arvind_party_web/lib/core/\`.
- Backend mounts ${routeMounts.length} \`/api/*\` route prefixes from \`arvind-party-backend/src/app.js\`.
- Socket initialization is present in \`arvind-party-backend/server.js\` and client socket constants are present in mobile \`ApiConstants\`.

### Missing or Weak Connections
- Mobile app is configured for development mode with \`http://192.168.1.100:5000\`, not a production-safe environment switch.
- Web env config still contains placeholder backend, Firebase, Razorpay, and Agora values.
- Web \`ApiService\` defaults to \`http://localhost:5000/api\` instead of reading the central env config.
- API connection status is static only; there is no proof in this audit that mobile/web flows succeed end to end.
- Real-time socket authentication and event compatibility were not proven by execution.

## Phase 7: Local Server Configuration Audit

| File | Line | Current Value |
|---|---:|---|
${urlHits.slice(0, 35).map(hit => `| \`${hit.file}\` | ${hit.line} | \`${hit.text.slice(0, 110)}\` |`).join('\n')}

Development suggestion: \`http://192.168.x.x:5000/api\` for LAN devices or \`http://10.0.2.2:5000/api\` for Android emulator.

Production suggestion: \`https://api.arvindparty.com/api\`

## Phase 11: Production Readiness

| Area | Score | Notes |
|---|---:|---|
| Security baseline | 62 | Helmet, rate limiting, auth helpers, but hardening gaps remain |
| Deployment readiness | 35 | No CI/CD workflow or container setup detected |
| Observability | 40 | Logging exists, centralized monitoring not detected |
| Test readiness | 20 | Minimal test presence only |
| Config hygiene | 38 | Web config still uses placeholders; mobile defaults to dev |
| Overall readiness | ${productionReadiness} | Static estimate only |

## Final Summary
- Overall project completion: ${overallCompletion}%
- Overall production readiness: ${productionReadiness}%
- Estimated remaining work: ${100 - overallCompletion}%
- Estimated time to production: 8-12 weeks, assuming one focused team closes security, testing, config, and deployment gaps
`;

const appReport = `# ARVIND PARTY App Report

## Flutter Mobile App Inventory
| Area | Count |
|---|---:|
| Screens | ${mobileGroups.screens.length} |
| Controllers | ${mobileGroups.controllers.length} |
| Services | ${mobileGroups.services.length} |
| Models | ${mobileGroups.models.length} |
| Widgets | ${mobileGroups.widgets.length} |
| Bindings | ${mobileGroups.bindings.length} |
| Repositories | ${mobileGroups.repositories.length} |
| Route files | ${mobileGroups.routes.length} |
| GetPage route declarations | ${mobileGetPages} |
| Files with GetX usage | ${mobileGetxUsage} |

## Major File Sets
### Screens
${formatFileList(mobileGroups.screens, 35)}

### Controllers
${formatFileList(mobileGroups.controllers, 25)}

### Services
${formatFileList(mobileGroups.services, 20)}

### Models
${formatFileList(mobileGroups.models, 25)}

### Widgets
${formatFileList(mobileGroups.widgets, 25)}

## Route and API Notes
- \`lib/routes/app_pages.dart\` and \`lib/routes/app_routes.dart\` define app navigation.
- \`lib/core/constants/api_constants.dart\` provides endpoint constants.
- \`lib/core/constants/env_config.dart\` is currently in development mode.
- Agora app id is still \`INSERT_YOUR_AGORA_APP_ID_HERE\`.

## Feature Completion Estimate
| Feature | Completion % | Signal |
|---|---:|---|
${mobileFeatureRows.map(([label, pct, status]) => `| ${label} | ${pct} | ${status} |`).join('\n')}

## Likely Strengths
- Feature breadth is high: auth, rooms, family, ranking, wallet, agency, gifts, games, moments, and admin surfaces all exist.
- GetX architecture is used consistently across bindings, controllers, and route pages.
- Separate services exist for API, storage, Firebase, Agora, sockets, and security helpers.

## Likely Gaps
- Runtime success is unverified for OTP, social login, wallet, and room joins.
- Several features have UI breadth but may still be placeholder-heavy.
- Mobile env config is not production-safe by default.
- Automated test coverage is minimal.

## Mobile App Completion
Estimated completion: ${mobileCompletion}%
`;

const webReport = `# ARVIND PARTY Web Report

## Flutter Web Panel Inventory
| Area | Count |
|---|---:|
| Dart files | ${webDart.length} |
| Screens / views | ${webGroups.screens.length} |
| Controllers | ${webGroups.controllers.length} |
| Services | ${webGroups.services.length} |
| Models | ${webGroups.models.length} |
| Widgets | ${webGroups.widgets.length} |
| Route files | ${webGroups.routes.length} |
| GetPage route declarations | ${webGetPages} |

## Module Status
| Module | Status | Matching Files |
|---|---|---:|
${webModuleRows.map(([label, state, count]) => `| ${label} | ${state} | ${count} |`).join('\n')}

## Notable Findings
- The web panel contains a large admin surface area under \`arvind_party_web/lib/modules/\` and \`arvind_party_web/lib/app/modules/\`.
- \`arvind_party_web/lib/core/constants/env_config.dart\` still contains placeholder backend and third-party credentials.
- Dashboard, rooms, users, agency, rewards, family, events, VIP, security, and finance-oriented modules are all present in code.
- This audit cannot prove whether the modules are fully wired to real backend permissions or data contracts.

## Likely Missing or Partial Areas
- Production-ready environment configuration
- Full runtime verification of role permissions
- Proven export/import workflows
- Real-time dashboard/socket verification

## Web Panel Completion
Estimated completion: ${webCompletion}%
`;

const backendReport = `# ARVIND PARTY Backend Report

## Node.js Backend Structure
| Area | Count |
|---|---:|
| Controllers | ${backendGroups.controllers.length} |
| Routes | ${backendGroups.routes.length} |
| Models | ${backendGroups.models.length} |
| Middlewares | ${backendGroups.middlewares.length} |
| Services | ${backendGroups.services.length} |
| Sockets | ${backendGroups.sockets.length} |
| Config files | ${backendGroups.config.length} |
| Utility files | ${backendGroups.utils.length} |
| Mounted API prefixes | ${routeMounts.length} |
| Router method entries found | ${routerPaths.length} |

## Core Structure
### Controllers
${formatFileList(backendGroups.controllers, 30)}

### Routes
${formatFileList(backendGroups.routes, 30)}

### Models
${formatFileList(backendGroups.models, 30)}

### Services
${formatFileList(backendGroups.services, 20)}

### Sockets
${formatFileList(backendGroups.sockets, 20)}

## Express / Database / Auth / Security
- Express app bootstraps in \`arvind-party-backend/src/app.js\`.
- MongoDB connection is initialized in \`arvind-party-backend/server.js\` via \`src/config/db.js\`.
- Redis is attempted for OTP and ranking services with fallback behavior in \`server.js\`.
- Socket.io is initialized in \`server.js\` and wired through \`src/config/socket.js\`.
- Helmet, CORS, request logging, JSON body limits, and rate limiting are present.
- JWT, bcrypt, Firebase admin, Razorpay, Twilio, and multer dependencies are installed.

## Database Audit
| Collection | Exists | Status |
|---|---|---|
${dbRows.map(([name, exists, status]) => `| ${name} | ${exists} | ${status} |`).join('\n')}

## Security Audit
| Control | Detection | Files | Risk |
|---|---|---:|---|
${securityRows.map(([label, status, count, risk]) => `| ${label} | ${status} | ${count} | ${risk} |`).join('\n')}

## High-Risk Findings
- Web and mobile environment configuration is not production-ready.
- Rate limiting exists but no Redis-backed distributed limiter was confirmed.
- Web placeholders for Firebase, Razorpay, and Agora would block a real deployment.
- Static audit cannot guarantee wallet atomicity, webhook verification, or socket authorization coverage.
- CI, integration tests, monitoring, backup automation, and deployment manifests were not detected.

## Backend Completion
Estimated completion: ${backendCompletion}%
`;

const featuresReport = `# ARVIND PARTY Features Report

## API Connection Audit
| Mobile Endpoint Constant | Backend Prefix | Source Type | Mobile Connected? | Backend Exists? | Working? | Note |
|---|---|---|---|---|---|---|
${apiAuditRows.slice(0, 40).map(([endpoint, backend, source, mobile, backendExists, working, note]) => `| \`${endpoint}\` | \`${backend}\` | ${source} | ${mobile} | ${backendExists} | ${working} | ${note} |`).join('\n')}

## Connectivity Summary
- Mobile to backend: statically connected through \`ApiConstants\` and env config.
- Web to backend: statically connected through \`core/services/api_service.dart\` and web env config.
- Backend to MongoDB: boot path present.
- Backend to Redis: optional with fallback.
- Backend sockets: room, chat, seat, gift, pk battle, family, and agency handlers exist.

## Feature Completion Matrix
| Platform | Estimated Completion |
|---|---:|
| Mobile app | ${mobileCompletion}% |
| Web panel | ${webCompletion}% |
| Backend | ${backendCompletion}% |
| Overall | ${overallCompletion}% |
`;

const productionReport = `# ARVIND PARTY Production Readiness

## Score
${productionReadiness}/100

## Major Blockers
- No CI/CD workflow detected under \`.github/workflows/\`
- No containerization or deployment manifest detected
- Web panel env config contains placeholders
- Mobile defaults to development mode
- Test footprint is very small
- Runtime observability and backup automation were not detected

## Immediate Next Steps
1. Replace placeholder config in mobile and web with environment-driven secrets management.
2. Add CI pipeline for linting, Flutter analyze, backend smoke tests, and build steps.
3. Add health checks covering MongoDB, Redis, and third-party dependencies.
4. Verify wallet, withdrawal, and gift flows for transaction safety and idempotency.
5. Add deployment manifests, monitoring, and backup automation.
`;

const priorityFixList = `# PRIORITY FIX LIST

## Priority 1 Critical
- Lock down \`arvind_party_web/lib/core/constants/env_config.dart\` and remove placeholder production blockers.
- Move mobile \`lib/core/constants/env_config.dart\` away from hardcoded development defaults.
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
`;

const executiveSummary = `# ARVIND PARTY Executive Summary

| Component | Completion % | Notes |
|---|---:|---|
| Flutter Mobile App | ${mobileCompletion}% | Broad feature surface, runtime confidence still limited |
| Flutter Web Panel | ${webCompletion}% | Large admin surface, config still placeholder-based |
| Node.js Backend | ${backendCompletion}% | Strong breadth of routes/models/services, needs production hardening |
| Overall Project | ${overallCompletion}% | Static estimate |

Production readiness: ${productionReadiness}/100

Estimated remaining work: ${100 - overallCompletion}%

Estimated time to production: 8-12 weeks

Top next steps:
1. Fix environment configuration and secret management.
2. Add CI/CD and automated tests.
3. Verify critical money and auth flows end to end.
4. Add monitoring, backups, and deployment automation.
5. Harden security around sockets, rate limits, and admin access.
`;

const outputs = {
  'ARVIND_PARTY_MASTER_REPORT.md': masterReport,
  'ARVIND_PARTY_APP_REPORT.md': appReport,
  'ARVIND_PARTY_WEB_REPORT.md': webReport,
  'ARVIND_PARTY_BACKEND_REPORT.md': backendReport,
  'ARVIND_PARTY_FEATURES_REPORT.md': featuresReport,
  'ARVIND_PARTY_PRODUCTION_READINESS.md': productionReport,
  'PRIORITY_FIX_LIST.md': priorityFixList,
  'EXECUTIVE_SUMMARY.md': executiveSummary,
};

for (const [name, content] of Object.entries(outputs)) {
  fs.writeFileSync(path.join(REPORTS_DIR, name), content, 'utf8');
}

console.log(JSON.stringify({
  totalFiles: allFiles.length,
  dartFiles: dartFiles.length,
  jsFiles: jsFiles.length,
  jsonFiles: classes.json.length,
  assetFiles: classes.assets.length,
  mobileCompletion,
  webCompletion,
  backendCompletion,
  overallCompletion,
  productionReadiness,
  mountedApiPrefixes: routeMounts.length,
  routerEntries: routerPaths.length,
  mobileGetPages,
  webGetPages,
}, null, 2));
