# Quickstart — neurowellnessdojo.com

## System Shape

Plain PHP 7.4+ landing page. No framework, no build, no JS, no database.
Single deployable unit. ~2K LOC, 45 files. Deployed to peec.biz shared hosting.

## Essential Commands

```bash
# Run tests (starts PHP built-in server on localhost:8765)
pytest tests/

# Start dev server (bind 0.0.0.0 for browser preview)
php -S 0.0.0.0:8080 -t .

# Deploy to production
./sync.sh --remote peec.biz

# Dry-run deploy preview
./sync.sh dryrun --remote peec.biz

# Setup config (first time)
cp config.example.php config.php
# Edit config.php with real values (gitignored)
```

## Architectural Boundaries

- **Pages** (`*.php` at root + `KC-dds-ref/`): render HTML, include shared parts
- **Includes** (`includes/*.php`): reusable functions (head, variant, mail, footer)
- **Config** (`config.php`): PHP array returned via `require`; gitignored
- **Styling** (`assets/css/styles.css`): single monolithic CSS file, dark theme
- **Tests** (`tests/test_pages.py`): Python/pytest integration tests against PHP server
- **Deploy** (`sync.sh`): rsync-based; inherited from quantumaikido.com, has legacy code

## Dependency Rules

- Pages `require` config + includes; includes never require pages
- `submit.php` is the only form handler; all forms POST to `/submit.php`
- `config.php` is consumed by every page via `require __DIR__ . '/config.php'`
- No Composer, no autoloader, no external PHP dependencies

## Coding Patterns

- `declare(strict_types=1)` at top of PHP files with logic (OBSERVED: 4 files)
- `htmlspecialchars($val, ENT_QUOTES, 'UTF-8')` for all HTML output (OBSERVED)
- Functions prefixed `nwd_` in includes (OBSERVED: `nwd_variant`, `nwd_terms`, `nwd_send_mail`, `nwd_notify_visit`)
- Session-based CSRF: generated in `head.php`, validated in `submit.php`
- Honeypot field `website` on forms with intake (index unlocked, KC-dds-ref)

## Highest-Risk Areas

1. `submit.php` — all security controls concentrated here
2. `config.php` — contains email addresses, webhook URL (gitignored)
3. `sync.sh` — 820-line deploy script with legacy quantumaikido.com references

## Navigation

→ See `index.md` for the full router and `architecture/` for data flows.
→ Before editing any component, check `change-impact/relationships.yaml`.
