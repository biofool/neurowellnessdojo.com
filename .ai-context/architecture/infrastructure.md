# Infrastructure Architecture

## Hosting

- **Server:** peec.biz (shared hosting)
- **User:** peecbiz
- **Path:** `public_html/neurowellnessdojo.com/`
- **SSH key:** `~/.ssh/quantumaikido_ed25519` (shared with quantumaikido.com)
- **PHP version:** 7.4+ required; 8.5.4 available locally

**Evidence:** OBSERVED — `sync.sh:6-8`, `CLAUDE.md:13-17`.

## Apache Configuration (`.htaccess`)

| Rule | Lines | Purpose |
|------|-------|---------|
| `DirectoryIndex index.php` | 1 | Default document |
| Deny `config.php`, `config.example.php` | 4-6 | Prevent direct access to config |
| Deny `includes/` directory | 8-10 | Prevent direct access to includes |
| HTTPS redirect | 13-15 | Force HTTPS (active, not commented) |
| 404 routing | 18-22 | Route non-existent files to `404.php` |
| `Options -Indexes` | 25 | Disable directory listing |
| `ServerSignature Off` | 26 | Hide Apache version |
| CSS cache | 29-30 | `Cache-Control: max-age=600, public` (10 min) |

**Evidence:** OBSERVED — `.htaccess` lines 1-31.

**Note:** CLAUDE.md states the HTTPS redirect is "commented out; uncomment
after SSL install" but the actual `.htaccess` has it **active** (lines 13-15).
See `decisions/conflicts.yaml` CONFLICT-001.

## Deployment (`sync.sh`)

820-line bash script. Auto-detects site name from directory basename.

### Relevant Commands for This Site

| Command | Description |
|---------|-------------|
| `./sync.sh deploy --remote peec.biz` | `git push` + rsync (no prompt) |
| `./sync.sh upload --remote peec.biz` | rsync with dry-run preview + confirm |
| `./sync.sh dryrun --remote peec.biz` | Preview only |
| `./sync.sh download --remote peec.biz` | Download from server |
| `./sync.sh logs` | Fetch access logs from peec.biz |
| `./sync.sh report` | Fetch logs + generate visitor statistics |
| `./sync.sh help` | Show all commands |

### Excludes (files NOT deployed)

The script excludes non-web files from rsync:
- `.git/`, `tests/`, `*.py`, `*.sh`, `*.md`, `*.pdf`, `*.docx`
- `config.php` is NOT excluded (deployed to server — needed at runtime)
- `sync.sh` itself is excluded (line 96)
- `logs/`, `.env`, `.claude/`, `.pytest_cache/`

**Evidence:** OBSERVED — `sync.sh:54-115` (EXCLUDES array).

### Legacy Code

`sync.sh` was inherited from quantumaikido.com and contains significant code
not used by this site:
- Video archive peer-to-peer sync (`push-uploads`, `pull-uploads`, `require_videoarchive`)
- Cache sync (`cache`, `push-cache`)
- Review data merge (`merge_review_files`, `pull-review`, `push-review`)
- Media sync (`media` — ClipQuotes, BerkeleyVideos)
- Access link hash generation (`hash`)
- Windows/Cygwin path support (lines 26-33)
- `.env` loading for `ARCHIVE_PEER_*` and `VIDEOARCHIVE` variables

**Evidence:** OBSERVED — `sync.sh` lines 36-51, 117-128, 277-324, 671-743.

## SEO Infrastructure

| File | Purpose |
|------|---------|
| `robots.txt` | Allow all, point to sitemap |
| `sitemap.xml` | 3 URLs: `/`, `/contact.php`, `/privacy.php` (lastmod 2026-05-20) |
| `includes/head.php` | Per-page `<meta name="robots">` (default `index,follow`) |

**Note:** `sitemap.xml` doesn't include `thank-you.php` or `404.php`.

**Evidence:** OBSERVED — `robots.txt`, `sitemap.xml`, `head.php:18`.

## External Integrations

### Google Apps Script (`apps-script.gs`)
- Deployed separately to Google Sheets (Extensions → Apps Script)
- Receives POST with JSON: `name`, `email`, `message`, `variant`, `referral`, `timestamp`
- Appends row to active sheet
- Returns JSON `{ok: true}` or `{ok: false, error: ...}`
- URL configured in `config.php` as `sheets_webhook_url`
- Currently empty in both `config.example.php` and `config.php` (OBSERVED)

**Evidence:** OBSERVED — `apps-script.gs` lines 1-33, `config.php:18`.

### Email
- PHP `mail()` via local sendmail binary
- From: `noreply@neurowellnessdojo.com` (example) / `coach@neurowellnessdojo.com` (actual config)
- To: `coach@neurowellnessdojo.com` (intake_email)
- Plain text, UTF-8

**Evidence:** OBSERVED — `includes/mail.php:8-18`, `config.php:9-14`.
