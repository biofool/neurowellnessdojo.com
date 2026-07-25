<!-- AI coding config version: 2026-07-25 — sourced from biofool/starter template. Shared settings across all biofool projects; see ~/.codeium/windsurf/memories/shared_template_config.md -->

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

Plain PHP 7.4+ landing page — no build step, no npm, no framework. Single monolithic CSS file (`assets/css/styles.css`). No JavaScript.

## Deployment

```bash
./sync.sh --remote peec.biz
```

`sync.sh` auto-detects the site name from its directory (`SITE_NAME`) and sets all remote paths accordingly — works for any site in `~/projects/<domain>/`. Uses `~/.ssh/quantumaikido_ed25519`.

## Configuration

```bash
cp config.example.php config.php
# Edit config.php with actual values (gitignored)
```

`config.php` returns a PHP array consumed by every page via `require`. It is never source-controlled. The keys are: `intake_email`, `mail_from`, `mail_from_name`, `sheets_webhook_url`, `site_url`, `variant_cookie`, `variant_cookie_ttl`, `maintenance`.

## Architecture

### Request flow

```
index.php (or contact.php)
  → includes/head.php      # session_start, CSRF token generation, HTML <head>
  → includes/variant.php   # sticky A/B cookie assignment
  → (form submitted) → submit.php
      → CSRF validation
      → honeypot check (silent success if triggered)
      → rate limit (1 submission / 60 s per session)
      → nwd_send_mail() via PHP mail()
      → optional POST to Google Apps Script webhook → Sheet row appended
      → redirect to thank-you.php
  → includes/footer.php
```

### A/B testing (`includes/variant.php`)

`nwd_variant()` returns `'A'` or `'B'` based on a sticky cookie. `nwd_terms()` returns variant-specific word swaps (somatic vs. mind/body language). Variant is set on first visit and held for one year.

### Email (`includes/mail.php`)

- `nwd_send_mail()` — thin wrapper around PHP `mail()` with consistent headers
- `nwd_notify_visit()` — emails intake address on page visit; throttled to once per session

### Sheet logging (`apps-script.gs`)

Google Apps Script webhook deployed separately. Receives POST from `submit.php`, appends a row: `timestamp | name | email | message | variant`. `sheets_webhook_url` in config must point to the published script URL.

### Security controls in `submit.php`

- CSRF token (generated in `head.php`, burned on success)
- Honeypot hidden field (bot hit → silent success, no email sent)
- Session-based rate limit: one real submission per 60 seconds
- `filter_var($email, FILTER_VALIDATE_EMAIL)` on the email field

### Apache config (`.htaccess`)

- Denies direct access to `config.php` and `includes/`
- Enables HTTPS redirect (commented out; uncomment after SSL install)
- Routes unknown paths to `404.php`
- Caches CSS assets for 7 days

