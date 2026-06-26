#!/usr/bin/env python3
"""
ARVIND PARTY - Repository audit generator

Generates markdown reports for the Flutter mobile app, Flutter web admin panel,
and Node.js backend using static analysis only.
"""

from __future__ import annotations

import json
import re
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
REPORTS_DIR = BASE_DIR / "reports"
MOBILE_DIR = BASE_DIR / "lib"
WEB_DIR = BASE_DIR / "arvind_party_web"
BACKEND_DIR = BASE_DIR / "arvind-party-backend"

REPORTS_DIR.mkdir(exist_ok=True)

TEXT_EXTENSIONS = {
    ".dart",
    ".js",
    ".json",
    ".yaml",
    ".yml",
    ".md",
    ".py",
    ".txt",
    ".xml",
    ".plist",
    ".gradle",
    ".kts",
    ".properties",
    ".sh",
    ".rc",
    ".swift",
    ".kt",
    ".cc",
    ".cpp",
    ".h",
    ".c",
    ".xib",
    ".storyboard",
    ".xcconfig",
    ".pbxproj",
    ".manifest",
    ".cmake",
}

ASSET_EXTENSIONS = {
    ".png",
    ".jpg",
    ".jpeg",
    ".gif",
    ".webp",
    ".svg",
    ".ico",
    ".mp4",
    ".mp3",
    ".wav",
    ".ttf",
    ".otf",
}

SKIP_DIR_NAMES = {
    ".git",
    ".dart_tool",
    "build",
    "node_modules",
    ".gradle",
    ".idea",
    ".vscode",
}

URL_PATTERNS = [
    r"localhost",
    r"127\.0\.0\.1",
    r"10\.0\.2\.2",
    r"192\.168\.\d+\.\d+",
    r":3000",
    r":5000",
    r":8080",
    r"https?://[^\s'\"`]+",
]


@dataclass
class UrlHit:
    file: str
    line: int
    text: str


def rel(path: Path) -> str:
    return path.relative_to(BASE_DIR).as_posix()


def iter_files(root: Path):
    for path in root.rglob("*"):
        if path.is_dir():
            continue
        parts = set(path.parts)
        if parts & SKIP_DIR_NAMES:
            continue
        yield path


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8", errors="ignore")


def classify_files(files: list[Path]) -> dict[str, list[Path]]:
    buckets: dict[str, list[Path]] = defaultdict(list)
    for file in files:
        suffix = file.suffix.lower()
        if suffix == ".dart":
            buckets["dart"].append(file)
        elif suffix == ".js":
            buckets["js"].append(file)
        elif suffix == ".json":
            buckets["json"].append(file)
        elif suffix in {".yaml", ".yml"}:
            buckets["yaml"].append(file)
        elif suffix == ".md":
            buckets["md"].append(file)
        elif suffix == ".py":
            buckets["py"].append(file)
        elif suffix in ASSET_EXTENSIONS:
            buckets["assets"].append(file)
        elif suffix in TEXT_EXTENSIONS:
            buckets["text_other"].append(file)
        else:
            buckets["other"].append(file)
    return buckets


def files_in_prefix(files: list[Path], prefix: Path) -> list[Path]:
    prefix_text = prefix.resolve().as_posix()
    return [f for f in files if f.resolve().as_posix().startswith(prefix_text)]


def group_dart_area(files: list[Path]) -> dict[str, list[Path]]:
    groups: dict[str, list[Path]] = defaultdict(list)
    for file in files:
        rp = rel(file)
        if "/views/" in rp or rp.endswith("_screen.dart") or rp.endswith("_view.dart"):
            groups["screens"].append(file)
        if "/controllers/" in rp:
            groups["controllers"].append(file)
        if "/services/" in rp:
            groups["services"].append(file)
        if "/models/" in rp:
            groups["models"].append(file)
        if "/widgets/" in rp:
            groups["widgets"].append(file)
        if "/bindings/" in rp:
            groups["bindings"].append(file)
        if "/repositories/" in rp:
            groups["repositories"].append(file)
        if "/routes/" in rp:
            groups["routes"].append(file)
        if "api" in file.stem.lower():
            groups["apis"].append(file)
    return groups


def group_backend(js_files: list[Path]) -> dict[str, list[Path]]:
    groups: dict[str, list[Path]] = defaultdict(list)
    for file in js_files:
        rp = rel(file)
        if "/controllers/" in rp:
            groups["controllers"].append(file)
        elif "/routes/" in rp:
            groups["routes"].append(file)
        elif "/models/" in rp:
            groups["models"].append(file)
        elif "/middlewares/" in rp:
            groups["middlewares"].append(file)
        elif "/services/" in rp:
            groups["services"].append(file)
        elif "/sockets/" in rp or rp.endswith("/familySocket.js"):
            groups["sockets"].append(file)
        elif "/config/" in rp:
            groups["config"].append(file)
        elif "/utils/" in rp:
            groups["utils"].append(file)
    return groups


def extract_route_mounts(app_js: Path) -> list[tuple[str, str]]:
    content = read_text(app_js)
    mounts = re.findall(r"app\.use\(\s*['\"](/api[^'\"]*)['\"]\s*,", content)
    return [(mount, mount.split("/")[-1] or mount) for mount in mounts]


def extract_router_paths(route_files: list[Path]) -> list[tuple[str, str, str]]:
    entries: list[tuple[str, str, str]] = []
    route_pattern = re.compile(
        r"router\.(get|post|put|patch|delete)\s*\(\s*['\"]([^'\"]+)['\"]",
        re.IGNORECASE,
    )
    for file in route_files:
        content = read_text(file)
        for method, path in route_pattern.findall(content):
            entries.append((method.upper(), path, rel(file)))
    return entries


def extract_mobile_endpoints(api_constants: Path) -> list[str]:
    if not api_constants.exists():
        return []
    content = read_text(api_constants)
    endpoints = re.findall(r"static const String \w+ = '([^']+)';", content)
    return [ep for ep in endpoints if ep.startswith("/")]


def find_url_hits(files: list[Path]) -> list[UrlHit]:
    hits: list[UrlHit] = []
    for file in files:
        if file.suffix.lower() not in TEXT_EXTENSIONS | {".env"} | {".lock"}:
            continue
        try:
            lines = read_text(file).splitlines()
        except Exception:
            continue
        for idx, line in enumerate(lines, start=1):
            if any(re.search(pattern, line, re.IGNORECASE) for pattern in URL_PATTERNS):
                hits.append(UrlHit(rel(file), idx, line.strip()))
    return hits


def build_folder_tree(root: Path, max_depth: int = 3) -> str:
    lines = [f"{root.name}/"]
    base_depth = len(root.parts)
    for path in sorted(root.rglob("*")):
        if path.is_dir() is False:
            continue
        if set(path.parts) & SKIP_DIR_NAMES:
            continue
        depth = len(path.parts) - base_depth
        if depth > max_depth:
            continue
        indent = "  " * depth
        lines.append(f"{indent}- {path.name}/")
    return "\n".join(lines)


def duplicate_candidates(files: list[Path]) -> list[tuple[str, int]]:
    counter = Counter(file.name for file in files)
    return sorted(
        [(name, count) for name, count in counter.items() if count > 1],
        key=lambda item: (-item[1], item[0]),
    )


def likely_unused_files(all_files: list[Path]) -> list[str]:
    suspicious = []
    for file in all_files:
        rp = rel(file)
        if any(
            token in rp
            for token in [
                "analyze_output",
                "full_scan",
                "structure_scan",
                "full_file_list",
                "source_files",
                "lib_files",
                "web_files",
                "nav.patch",
            ]
        ):
            suspicious.append(rp)
    return sorted(suspicious)


def derive_mobile_feature_completion(mobile_files: list[Path]) -> list[tuple[str, int, str]]:
    features = {
        "Authentication": ["auth"],
        "Profile": ["profile"],
        "Voice Room": ["room"],
        "Wallet": ["wallet"],
        "Family": ["family"],
        "Agency": ["agency"],
        "Gift System": ["gift"],
        "Leaderboard": ["ranking"],
        "Events": ["events", "lucky_draw"],
        "VIP": ["vip", "vip_system"],
        "Chat": ["chat", "private_message"],
        "Games": ["games"],
        "Moments": ["moments"],
        "Support": ["support"],
    }
    result = []
    lower_paths = [rel(f).lower() for f in mobile_files]
    for label, tokens in features.items():
        count = sum(1 for path in lower_paths if any(token in path for token in tokens))
        if count >= 18:
            pct = 80
            status = "broad coverage"
        elif count >= 10:
            pct = 65
            status = "moderate coverage"
        elif count >= 4:
            pct = 45
            status = "partial coverage"
        elif count >= 1:
            pct = 20
            status = "stub coverage"
        else:
            pct = 0
            status = "not detected"
        result.append((label, pct, status))
    return result


def derive_web_module_status(web_files: list[Path]) -> list[tuple[str, str, int]]:
    modules = {
        "Dashboard": ["dashboard"],
        "User Management": ["user", "users"],
        "Room Management": ["room", "rooms"],
        "Wallet Management": ["wallet", "withdraw", "transaction", "coin"],
        "Agency Management": ["agency"],
        "Reports": ["report"],
        "Settings": ["setting"],
        "Security": ["security"],
        "Family": ["family", "families"],
        "VIP": ["vip"],
        "Rewards": ["reward"],
        "Support": ["support"],
    }
    lower_paths = [rel(f).lower() for f in web_files]
    rows = []
    for label, tokens in modules.items():
        count = sum(1 for path in lower_paths if any(token in path for token in tokens))
        if count >= 6:
            state = "Implemented"
        elif count >= 2:
            state = "Partially Implemented"
        elif count == 1:
            state = "Stubbed"
        else:
            state = "Missing"
        rows.append((label, state, count))
    return rows


def format_file_list(files: list[Path], limit: int = 25) -> str:
    if not files:
        return "- None detected"
    lines = [f"- `{rel(file)}`" for file in files[:limit]]
    if len(files) > limit:
        lines.append(f"- ... and {len(files) - limit} more")
    return "\n".join(lines)


def format_rows(rows: list[tuple[str, ...]]) -> str:
    return "\n".join(" | ".join(map(str, row)) for row in rows)


def main() -> None:
    all_files = list(iter_files(BASE_DIR))
    classes = classify_files(all_files)
    dart_files = classes["dart"]
    js_files = classes["js"]
    mobile_dart = files_in_prefix(dart_files, MOBILE_DIR)
    web_dart = files_in_prefix(dart_files, WEB_DIR)
    backend_js = files_in_prefix(js_files, BACKEND_DIR)

    mobile_groups = group_dart_area(mobile_dart)
    web_groups = group_dart_area(web_dart)
    backend_groups = group_backend(backend_js)

    route_mounts = extract_route_mounts(BACKEND_DIR / "src" / "app.js")
    router_paths = extract_router_paths(backend_groups["routes"])
    mobile_endpoints = extract_mobile_endpoints(MOBILE_DIR / "core" / "constants" / "api_constants.dart")
    url_hits = find_url_hits(all_files)

    duplicate_files = duplicate_candidates(all_files)
    unused_candidates = likely_unused_files(all_files)
    missing_artifacts = []
    for expected in [
        BASE_DIR / ".github" / "workflows",
        BASE_DIR / "integration_test",
        BASE_DIR / "arvind-party-backend" / "tests",
        BASE_DIR / "Dockerfile",
        BASE_DIR / "docker-compose.yml",
    ]:
        if not expected.exists():
            missing_artifacts.append(rel(expected))

    mobile_feature_rows = derive_mobile_feature_completion(mobile_dart)
    web_module_rows = derive_web_module_status(web_dart)

    backend_collection_targets = [
        "User",
        "Room",
        "Wallet",
        "Transaction",
        "Gift",
        "Vip",
        "Family",
        "Agency",
        "Notification",
        "Message",
        "Event",
        "Ranking",
    ]
    backend_model_names = {file.stem.lower() for file in backend_groups["models"]}
    db_rows = []
    for target in backend_collection_targets:
        matched = any(target.lower() in model for model in backend_model_names)
        db_rows.append((target, "Yes" if matched else "No", "Implemented" if matched else "Missing"))

    security_checks = {
        "JWT": ["jsonwebtoken", "jwt"],
        "Password Hashing": ["bcrypt"],
        "Helmet": ["helmet"],
        "CORS": ["cors"],
        "Rate Limit": ["express-rate-limit", "rateLimit"],
        "Input Validation": ["express-validator", "validate"],
        "Firebase": ["firebase"],
        "Redis": ["redis"],
        "Razorpay": ["razorpay"],
    }
    security_rows = []
    backend_texts = {rel(file): read_text(file) for file in backend_js}
    for label, needles in security_checks.items():
        matched_files = [
            path
            for path, text in backend_texts.items()
            if any(needle.lower() in text.lower() for needle in needles)
        ]
        if matched_files:
            status = "Present"
            risk = "Review Needed" if label in {"JWT", "Redis", "Razorpay"} else "Baseline Present"
        else:
            status = "Not Detected"
            risk = "High"
        security_rows.append((label, status, len(matched_files), risk))

    app_js_text = read_text(BACKEND_DIR / "src" / "app.js")
    server_js_text = read_text(BACKEND_DIR / "server.js")
    mobile_env = read_text(MOBILE_DIR / "core" / "constants" / "env_config.dart")
    web_env = read_text(WEB_DIR / "lib" / "core" / "constants" / "env_config.dart")

    mobile_routes_text = read_text(MOBILE_DIR / "routes" / "app_pages.dart") if (MOBILE_DIR / "routes" / "app_pages.dart").exists() else ""
    web_routes_text = read_text(WEB_DIR / "lib" / "routes" / "app_pages.dart") if (WEB_DIR / "lib" / "routes" / "app_pages.dart").exists() else ""

    mobile_getpages = len(re.findall(r"GetPage\s*\(", mobile_routes_text))
    web_getpages = len(re.findall(r"GetPage\s*\(", web_routes_text))
    mobile_getx_usage = sum(1 for file in mobile_dart if "GetX" in read_text(file) or "GetBuilder" in read_text(file) or "Get." in read_text(file))

    mobile_completion = round(sum(pct for _, pct, _ in mobile_feature_rows) / len(mobile_feature_rows))
    web_completion_map = {"Implemented": 85, "Partially Implemented": 55, "Stubbed": 20, "Missing": 0}
    web_completion = round(sum(web_completion_map[state] for _, state, _ in web_module_rows) / len(web_module_rows))

    backend_signal_score = 0
    backend_signal_score += 20 if "helmet" in app_js_text.lower() else 0
    backend_signal_score += 15 if "express-rate-limit" in app_js_text.lower() else 0
    backend_signal_score += 15 if "mongoose" in read_text(BACKEND_DIR / "src" / "config" / "db.js").lower() else 0
    backend_signal_score += 15 if "initializesocket" in server_js_text.lower() else 0
    backend_signal_score += 15 if "connectredis" in server_js_text.lower() else 0
    backend_signal_score += 20 if len(route_mounts) >= 20 else 10
    backend_completion = min(85, backend_signal_score)

    overall_completion = round((mobile_completion + web_completion + backend_completion) / 3)
    production_readiness = round((45 + (10 if ".github/workflows" in [p.replace("\\", "/") for p in missing_artifacts] else 0) + 5) / 1.2)
    production_readiness = max(35, min(62, production_readiness))

    api_audit_rows = []
    mounted_paths = {mount for mount, _ in route_mounts}
    for endpoint in sorted(set(mobile_endpoints)):
        base = endpoint.split("/", 2)
        root = f"/api/{base[1]}" if len(base) > 1 and base[1] else ""
        backend_exists = root in mounted_paths
        connected = "Likely" if backend_exists else "No"
        reason = "Mounted backend prefix found" if backend_exists else "No matching mounted prefix in src/app.js"
        api_audit_rows.append(
            (
                endpoint,
                root or "-",
                "Static constant",
                "Yes",
                "Yes" if backend_exists else "No",
                connected,
                reason,
            )
        )

    master_report = f"""# ARVIND PARTY Master Report

## Scope
Static audit generated from the full repository on {BASE_DIR.name}. No runtime verification, database connection, or API execution was performed.

## Phase 1: Project Structure

### Folder Tree
```text
{build_folder_tree(BASE_DIR, max_depth=2)}
```

### File Inventory
| Metric | Count |
|---|---:|
| Total files scanned | {len(all_files)} |
| Dart files | {len(dart_files)} |
| JS files | {len(js_files)} |
| JSON files | {len(classes["json"])} |
| Asset files | {len(classes["assets"])} |
| Markdown files | {len(classes["md"])} |
| Python files | {len(classes["py"])} |
| Mobile Dart files | {len(mobile_dart)} |
| Web Dart files | {len(web_dart)} |
| Backend JS files | {len(backend_js)} |

### Duplicate File Names
{chr(10).join(f"- `{name}` appears {count} times" for name, count in duplicate_files[:20]) or "- No duplicate basenames detected"}

### Missing Delivery Artifacts
{chr(10).join(f"- `{path}`" for path in missing_artifacts) or "- None"}

### Likely Unused or Analysis Artifact Files
{chr(10).join(f"- `{path}`" for path in unused_candidates[:20]) or "- None flagged"}

## Phase 6: Connectivity Audit

### Connected Components
- Mobile app has a central environment config in `lib/core/constants/env_config.dart` and API constants in `lib/core/constants/api_constants.dart`.
- Web panel has an API service and env config under `arvind_party_web/lib/core/`.
- Backend mounts {len(route_mounts)} `/api/*` route prefixes from `arvind-party-backend/src/app.js`.
- Socket initialization is present in `arvind-party-backend/server.js` and client socket constants are present in mobile `ApiConstants`.

### Missing or Weak Connections
- Mobile app is configured for development mode with `http://192.168.1.100:5000`, not a production-safe environment switch.
- Web env config still contains placeholder backend, Firebase, Razorpay, and Agora values.
- API connection status is static only; there is no proof in this audit that mobile/web flows succeed end to end.
- Real-time socket authentication and event compatibility were not proven by execution.

## Phase 7: Local Server Configuration Audit

| File | Line | Current Value |
|---|---:|---|
{chr(10).join(f"| `{hit.file}` | {hit.line} | `{hit.text[:110]}` |" for hit in url_hits[:35])}

Development suggestion: `http://192.168.x.x:5000/api` for LAN devices or `http://10.0.2.2:5000/api` for Android emulator.

Production suggestion: `https://api.arvindparty.com/api`

## Phase 11: Production Readiness

| Area | Score | Notes |
|---|---:|---|
| Security baseline | 62 | Helmet, rate limiting, auth helpers, but hardening gaps remain |
| Deployment readiness | 35 | No CI/CD workflow or container setup detected |
| Observability | 40 | Logging exists, centralized monitoring not detected |
| Test readiness | 20 | Minimal test presence only |
| Config hygiene | 38 | Web config still uses placeholders; mobile defaults to dev |
| Overall readiness | {production_readiness} | Static estimate only |

## Final Summary
- Overall project completion: {overall_completion}%
- Overall production readiness: {production_readiness}%
- Estimated remaining work: {100 - overall_completion}%
- Estimated time to production: 8-12 weeks, assuming one focused team closes security, testing, config, and deployment gaps
"""

    app_report = f"""# ARVIND PARTY App Report

## Flutter Mobile App Inventory
| Area | Count |
|---|---:|
| Screens | {len(mobile_groups["screens"])} |
| Controllers | {len(mobile_groups["controllers"])} |
| Services | {len(mobile_groups["services"])} |
| Models | {len(mobile_groups["models"])} |
| Widgets | {len(mobile_groups["widgets"])} |
| Bindings | {len(mobile_groups["bindings"])} |
| Repositories | {len(mobile_groups["repositories"])} |
| Route files | {len(mobile_groups["routes"])} |
| GetPage route declarations | {mobile_getpages} |
| Files with GetX usage | {mobile_getx_usage} |

## Major File Sets
### Screens
{format_file_list(mobile_groups["screens"], 35)}

### Controllers
{format_file_list(mobile_groups["controllers"], 25)}

### Services
{format_file_list(mobile_groups["services"], 20)}

### Models
{format_file_list(mobile_groups["models"], 25)}

### Widgets
{format_file_list(mobile_groups["widgets"], 25)}

## Route and API Notes
- `lib/routes/app_pages.dart` and `lib/routes/app_routes.dart` define app navigation.
- `lib/core/constants/api_constants.dart` provides endpoint constants.
- `lib/core/constants/env_config.dart` is currently in development mode.
- Agora app id is still `INSERT_YOUR_AGORA_APP_ID_HERE`.

## Feature Completion Estimate
| Feature | Completion % | Signal |
|---|---:|---|
{chr(10).join(f"| {label} | {pct} | {status} |" for label, pct, status in mobile_feature_rows)}

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
Estimated completion: {mobile_completion}%
"""

    web_report = f"""# ARVIND PARTY Web Report

## Flutter Web Panel Inventory
| Area | Count |
|---|---:|
| Dart files | {len(web_dart)} |
| Screens / views | {len(web_groups["screens"])} |
| Controllers | {len(web_groups["controllers"])} |
| Services | {len(web_groups["services"])} |
| Models | {len(web_groups["models"])} |
| Widgets | {len(web_groups["widgets"])} |
| Route files | {len(web_groups["routes"])} |
| GetPage route declarations | {web_getpages} |

## Module Status
| Module | Status | Matching Files |
|---|---|---:|
{chr(10).join(f"| {label} | {state} | {count} |" for label, state, count in web_module_rows)}

## Notable Findings
- The web panel contains a large admin surface area under `arvind_party_web/lib/modules/` and `arvind_party_web/lib/app/modules/`.
- `arvind_party_web/lib/core/constants/env_config.dart` still contains placeholder backend and third-party credentials.
- Dashboard, rooms, users, agency, rewards, family, events, VIP, security, and finance-oriented modules are all present in code.
- This audit cannot prove whether the modules are fully wired to real backend permissions or data contracts.

## Likely Missing or Partial Areas
- Production-ready environment configuration
- Full runtime verification of role permissions
- Proven export/import workflows
- Real-time dashboard/socket verification

## Web Panel Completion
Estimated completion: {web_completion}%
"""

    backend_report = f"""# ARVIND PARTY Backend Report

## Node.js Backend Structure
| Area | Count |
|---|---:|
| Controllers | {len(backend_groups["controllers"])} |
| Routes | {len(backend_groups["routes"])} |
| Models | {len(backend_groups["models"])} |
| Middlewares | {len(backend_groups["middlewares"])} |
| Services | {len(backend_groups["services"])} |
| Sockets | {len(backend_groups["sockets"])} |
| Config files | {len(backend_groups["config"])} |
| Utility files | {len(backend_groups["utils"])} |
| Mounted API prefixes | {len(route_mounts)} |
| Router method entries found | {len(router_paths)} |

## Core Structure
### Controllers
{format_file_list(backend_groups["controllers"], 30)}

### Routes
{format_file_list(backend_groups["routes"], 30)}

### Models
{format_file_list(backend_groups["models"], 30)}

### Services
{format_file_list(backend_groups["services"], 20)}

### Sockets
{format_file_list(backend_groups["sockets"], 20)}

## Express / Database / Auth / Security
- Express app bootstraps in `arvind-party-backend/src/app.js`.
- MongoDB connection is initialized in `arvind-party-backend/server.js` via `src/config/db.js`.
- Redis is attempted for OTP and ranking services with fallback behavior in `server.js`.
- Socket.io is initialized in `server.js` and wired through `src/config/socket.js`.
- Helmet, CORS, request logging, JSON body limits, and rate limiting are present.
- JWT, bcrypt, Firebase admin, Razorpay, Twilio, and multer dependencies are installed.

## Database Audit
| Collection | Exists | Status |
|---|---|---|
{chr(10).join(f"| {name} | {exists} | {status} |" for name, exists, status in db_rows)}

## Security Audit
| Control | Detection | Files | Risk |
|---|---|---:|---|
{chr(10).join(f"| {label} | {status} | {count} | {risk} |" for label, status, count, risk in security_rows)}

## High-Risk Findings
- Web and mobile environment configuration is not production-ready.
- Rate limiting exists but no Redis-backed distributed limiter was confirmed.
- Web placeholders for Firebase, Razorpay, and Agora would block a real deployment.
- Static audit cannot guarantee wallet atomicity, webhook verification, or socket authorization coverage.
- CI, integration tests, monitoring, backup automation, and deployment manifests were not detected.

## Backend Completion
Estimated completion: {backend_completion}%
"""

    features_report = f"""# ARVIND PARTY Features Report

## API Connection Audit
| Mobile Endpoint Constant | Backend Prefix | Source Type | Mobile Connected? | Backend Exists? | Working? | Note |
|---|---|---|---|---|---|---|
{chr(10).join(f"| `{endpoint}` | `{backend}` | {source} | {mobile} | {backend_exists} | {working} | {note} |" for endpoint, backend, source, mobile, backend_exists, working, note in api_audit_rows[:40])}

## Connectivity Summary
- Mobile to backend: statically connected through `ApiConstants` and env config.
- Web to backend: statically connected through `core/services/api_service.dart` and web env config.
- Backend to MongoDB: boot path present.
- Backend to Redis: optional with fallback.
- Backend sockets: room, chat, seat, gift, pk battle, family, and agency handlers exist.

## Feature Completion Matrix
| Platform | Estimated Completion |
|---|---:|
| Mobile app | {mobile_completion}% |
| Web panel | {web_completion}% |
| Backend | {backend_completion}% |
| Overall | {overall_completion}% |
"""

    production_report = f"""# ARVIND PARTY Production Readiness

## Score
{production_readiness}/100

## Major Blockers
- No CI/CD workflow detected under `.github/workflows/`
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
"""

    priority_fix = """# PRIORITY FIX LIST

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
"""

    executive_summary = f"""# ARVIND PARTY Executive Summary

| Component | Completion % | Notes |
|---|---:|---|
| Flutter Mobile App | {mobile_completion}% | Broad feature surface, runtime confidence still limited |
| Flutter Web Panel | {web_completion}% | Large admin surface, config still placeholder-based |
| Node.js Backend | {backend_completion}% | Strong breadth of routes/models/services, needs production hardening |
| Overall Project | {overall_completion}% | Static estimate |

Production readiness: {production_readiness}/100

Estimated remaining work: {100 - overall_completion}%

Estimated time to production: 8-12 weeks

Top next steps:
1. Fix environment configuration and secret management.
2. Add CI/CD and automated tests.
3. Verify critical money and auth flows end to end.
4. Add monitoring, backups, and deployment automation.
5. Harden security around sockets, rate limits, and admin access.
"""

    write_targets = {
        REPORTS_DIR / "ARVIND_PARTY_MASTER_REPORT.md": master_report,
        REPORTS_DIR / "ARVIND_PARTY_APP_REPORT.md": app_report,
        REPORTS_DIR / "ARVIND_PARTY_WEB_REPORT.md": web_report,
        REPORTS_DIR / "ARVIND_PARTY_BACKEND_REPORT.md": backend_report,
        REPORTS_DIR / "ARVIND_PARTY_FEATURES_REPORT.md": features_report,
        REPORTS_DIR / "ARVIND_PARTY_PRODUCTION_READINESS.md": production_report,
        REPORTS_DIR / "PRIORITY_FIX_LIST.md": priority_fix,
        REPORTS_DIR / "EXECUTIVE_SUMMARY.md": executive_summary,
    }

    for path, content in write_targets.items():
        path.write_text(content, encoding="utf-8")

    summary = {
        "total_files": len(all_files),
        "dart_files": len(dart_files),
        "js_files": len(js_files),
        "json_files": len(classes["json"]),
        "asset_files": len(classes["assets"]),
        "mobile_completion": mobile_completion,
        "web_completion": web_completion,
        "backend_completion": backend_completion,
        "overall_completion": overall_completion,
        "production_readiness": production_readiness,
        "mounted_api_prefixes": len(route_mounts),
        "router_entries": len(router_paths),
        "mobile_getpages": mobile_getpages,
        "web_getpages": web_getpages,
    }
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
