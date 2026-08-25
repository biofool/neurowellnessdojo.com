# Change Impact Index

Before modifying any component, check `relationships.yaml` for:
- Dependencies (what it needs)
- Dependents (what needs it)
- Co-changed files
- Security/ops sensitivity
- Test map target

## High-Impact Components (modify with caution)

1. **`submit.php`** — all security controls; change affects all forms
2. **`includes/variant.php`** — change affects all page rendering
3. **`includes/head.php`** — change affects all pages (session, CSRF, nav)
4. **`config.php`** — change affects every page (loaded via require)
5. **`.htaccess`** — change affects access control (server-only, not testable)

## Low-Impact Components

- `privacy.php`, `thank-you.php`, `404.php` — static content, isolated
- `assets/css/styles.css` — styling only, no logic
- `sitemap.xml`, `robots.txt` — SEO metadata, no code dependencies
