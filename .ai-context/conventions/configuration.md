# Configuration Conventions

## config.php

- **Format:** PHP file returning an associative array
- **Loading:** `$config = require __DIR__ . '/config.php';`
- **Git status:** Gitignored (`.gitignore:10`), never committed
- **Template:** `config.example.php` (committed, same structure)

## Config Keys

| Key | Type | Example Value | Used By |
|-----|------|---------------|---------|
| `intake_email` | string | `coach@neurowellnessdojo.com` | submit.php, mail.php |
| `mail_from` | string | `noreply@neurowellnessdojo.com` | mail.php |
| `mail_from_name` | string | `Neuro Wellness Dojo` | mail.php |
| `sheets_webhook_url` | string (URL or empty) | `''` (empty = disabled) | submit.php |
| `site_url` | string (URL) | `https://neurowellnessdojo.com` | (declared but not used in code) |
| `variant_cookie` | string | `nwd_variant` | variant.php |
| `variant_cookie_ttl` | int (seconds) | `31536000` (1 year) | variant.php |
| `maintenance` | bool | `false` | index.php, contact.php, KC-dds-ref/index.php |

**Evidence:** OBSERVED — `config.example.php:5-29`, `config.php:5-29`.

## Discrepancy: config.example.php vs config.php

| Key | config.example.php | config.php (local) |
|-----|--------------------|--------------------|
| `mail_from` | `noreply@neurowellnessdojo.com` | `coach@neurowellnessdojo.com` |
| `mail_from_name` | `Neuro Wellness Dojo` | `Neuro Wellness Coach` |

**Evidence:** OBSERVED — `config.example.php:13-14` vs `config.php:13-14`.
This is expected: config.php has production-specific values, config.example.php
has template defaults.

## site_url — DECLARED but unused

`site_url` is declared in config but not referenced by any PHP file.
INFERRED: intended for absolute URLs in email bodies, but email bodies use
relative paths or no URLs.

**Evidence:** OBSERVED — grep for `site_url` finds only config files, no usage.

## Deployment Configuration

### sync.sh
- `KNOWN_REMOTES` array: peec.biz (production), 10.3.0.122 (LAN)
- SSH key: `~/.ssh/quantumaikido_ed25519`
- Excludes: defined in EXCLUDES array (lines 54-115)
- `.env` file (optional, gitignored): `ARCHIVE_PEER_*`, `VIDEOARCHIVE` (legacy)

### .gitignore
- Secrets: `.env`, `.env.*`, `*.key`, `*.pem`, `credentials.json`, `cookies.txt`
- Config: `config.php`
- Logs: `logs/`
- Test/cache: `.pytest_cache/`, `__pycache__/`, `*.py[cod]`
- Editor: `*.swp`, `*.swo`
- Local: `.claude/settings.local.json`, `.devin/config.local.json`

**Evidence:** OBSERVED — `.gitignore:1-28`.

## Environment Requirements

| Requirement | Minimum | Local | Evidence |
|-------------|---------|-------|----------|
| PHP | 7.4+ | 8.5.4 | CLAUDE.md, `php --version` |
| Python | 3.10+ (for `str \| None` syntax) | 3.14.4 | `tests/test_pages.py:44` |
| pytest | 9.0+ | 9.1.1 | `pytest.ini`, test run |
| requests | any | installed | `tests/test_pages.py:17` |
| sendmail | any | not found | `includes/mail.php:17` |
| rsync | any | available | `sync.sh:21` |
| ssh | any | available | `sync.sh:24` |
