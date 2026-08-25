# Architecture Index

## Files

| File | Content |
|------|---------|
| [system-overview.md](system-overview.md) | System context, deployable units, data flows, trust boundaries |
| [frontend.md](frontend.md) | Page structure, rendering pipeline, shared includes |
| [infrastructure.md](infrastructure.md) | Apache config, deployment, SEO, external integrations |

## Key Architectural Facts

- **No database.** All state is in PHP sessions, cookies, and an external
  Google Sheet (via Apps Script webhook). Email is the source of truth.
- **No JavaScript.** A/B testing is server-side. No client-side tracking.
- **Single deployable unit.** All PHP files served from webroot on peec.biz.
- **Security is concentrated in `submit.php`.** CSRF, honeypot, rate-limit,
  email validation — all in one 104-line file.
- **`config.php` is the only secret-bearing file.** Gitignored, never committed.
- **`.htaccess` is server-only.** Not enforced by `php -S` (test environment).
