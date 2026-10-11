# Technology Underpinnings — neurowellnessdojo.com

## Stack

Plain PHP 7.4+. No framework, no Composer, no npm, no JavaScript, no build
step. One stylesheet (`assets/css/styles.css`). Runs on any PHP-capable
host, including cheap shared hosting (deployed to peec.biz via `sync.sh`).

## Features and how they are implemented

### Pages

- `index.php` — landing page. Renders in two states: locked (public teaser +
  referral-code form) and unlocked (full page + intake form).
- `contact.php` — standalone contact/intake form (no gate).
- `privacy.php` — privacy policy. `thank-you.php` — post-submit confirmation.
  `404.php` — error page.
- `includes/head.php` — starts the session, generates the CSRF token, emits
  the HTML `<head>`, skip link, and nav. `includes/footer.php` closes the
  layout.

### Referral code gate (`index.php`, lines 19–34)

A POST to `/` with `access_code` is compared (case-insensitive) against a
hardcoded code (`DrClemans`). On match it sets `$_SESSION['clemans_unlocked']`.
This is a session flag, not authentication — it controls content visibility
only.

### Server-side A/B testing (`includes/variant.php`)

- `nwd_variant()` reads a cookie (name and TTL from `config.php`). If absent
  or invalid it assigns `A` or `B` with `mt_rand()` and sets a one-year
  `httponly`/`samesite=Lax` cookie. No JavaScript involved.
- `nwd_terms()` returns the variant's word swaps: `somatic` language for A,
  `mind/body` language for B. Pages render `$t['opening_para']`,
  `$t['discipline']`, and `$t['lineage_phrase']`.
- The variant is submitted as a hidden form field so conversions can be
  attributed per variant in the Sheet.

### Intake form handling (`submit.php`)

Validation pipeline, in order:

1. POST-only — anything else gets 405.
2. CSRF — `hash_equals()` against the session token minted in `head.php`;
   the token is burned (`unset($_SESSION['csrf'])`) after a successful
   submit so it cannot be replayed.
3. Honeypot — a hidden `website` field; if filled, the request gets a
   silent redirect to `thank-you.php` (fake success, nothing sent).
4. Rate limit — one real submission per 60 seconds per session.
5. Field checks — `filter_var(..., FILTER_VALIDATE_EMAIL)` on email,
   length caps on all fields, variant whitelisted to `A|B`.

Delivery is dual-channel:

- Email via `nwd_send_mail()` (`includes/mail.php`) — a thin wrapper around
  PHP `mail()` that sets From/X-Mailer/Content-Type headers and a `Reply-To`
  with the visitor's address. Email is the source of truth.
- Google Sheets — a JSON POST to `sheets_webhook_url` via
  `file_get_contents()` + `stream_context_create()` (5 s timeout,
  `ignore_errors`). Failures do not block the redirect.

### Google Apps Script webhook (`apps-script.gs`)

A standalone Apps Script `doPost` deployed as a web app ("execute as me",
access "Anyone"). It appends a row — timestamp, name, email, message,
variant — to the bound Sheet. The URL goes in `config.php` as
`sheets_webhook_url`.

### Visit notifications (`includes/mail.php`, `nwd_notify_visit()`)

Emails the intake address once per session per page with URL, referrer, IP,
and user agent. Used on `index.php` and `contact.php`.

### Configuration (`config.php`, template `config.example.php`)

`config.php` returns a PHP array consumed by every page via `require`. It is
gitignored and never committed. Keys: `intake_email`, `mail_from`,
`mail_from_name`, `sheets_webhook_url`, `site_url`, `variant_cookie`,
`variant_cookie_ttl`, `maintenance` (a 503 kill switch checked at the top of
each page).

### Apache layer (`.htaccess`)

Denies direct web access to `config.php` and `includes/`, routes unknown
paths to `404.php`, caches CSS for 7 days, and contains a commented-out
HTTPS redirect to enable after SSL is installed. Note: these protections
only apply under Apache — the PHP built-in dev server ignores them.

### Deployment (`sync.sh`)

Bash + rsync over SSH (`~/.ssh/quantumaikido_ed25519`). Auto-detects the site
name from the directory. Known remotes: `peec.biz` (production,
`public_html/<site>/`) and a LAN host. Commands include `upload`,
`download`, `dryrun`, `logs`, and more — run `./sync.sh help`. Every
mutating sync shows a dry-run preview and asks for confirmation.

### Tests (`tests/test_pages.py`)

A pytest + requests integration suite. A session fixture starts
`php -S localhost:8765` against the repo root, then tests page rendering,
the code gate, and `submit.php` security (method, CSRF, honeypot). Run:
`pytest tests/`. Caveat noted in the docstring: `.htaccess` rules are not
enforced by `php -S`.

## Known limitations

- No database — state lives in sessions, cookies, and the Google Sheet.
- The code gate is not real authentication; a determined visitor can bypass it.
- `mail()` depends on host sendmail; deliverability may need an SMTP relay.
- No built-in analytics or A/B reporting — compare variants manually.
- No third-party requests at runtime: fonts come from the system stack in
  `assets/css/styles.css`; the only outbound call is the optional Sheets
  webhook.
