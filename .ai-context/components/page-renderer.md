# Component: page-renderer

**Path:** `index.php` (198 lines), `contact.php` (70 lines), `includes/head.php`
(38 lines), `includes/footer.php` (17 lines)
**Revision:** d77a399

## Responsibility

Renders all public-facing HTML pages. Shared head/footer includes provide
consistent navigation, session management, CSRF tokens, and styling.

## Page Structure

### `index.php` — Home (code-gated)
- Loads config, mail, variant includes
- Maintenance check (503)
- POST handler for access code ("DrClemans") → sets `$_SESSION['clemans_unlocked']`
- **Locked view:** hero, description, FAQ, referral code form
- **Unlocked view:** hero (Clemans-specific), description, intake form, FAQ
- Visit notification on every load

### `contact.php` — Contact
- Loads config, mail, variant includes
- Maintenance check (503)
- Hero, intake form (no honeypot), contact email link
- Visit notification on every load

### `privacy.php` — Privacy Policy
- Static content, only includes head/footer
- No config, no variant, no mail

### `thank-you.php` — Thank You
- Static content, only includes head/footer

### `404.php` — Not Found
- Sets 404 status code, includes head/footer

## Shared Includes

### `includes/head.php`
- **Expects:** `$page_title` (string), `$current_page` (string), `$meta_robots` (optional)
- **Provides:** session_start, CSRF token, HTML `<head>`, header nav
- **Nav links:** Home (`/`), Contact (`/contact.php`), Privacy (`/privacy.php`)
- **Active page:** `aria-current="page"` on matching nav link

### `includes/footer.php`
- **Hardcoded:** `coach@neurowellnessdojo.com` (line 9)
- **Dynamic:** copyright year via `date('Y')`

## Dependencies

| Dependency | Type | Evidence |
|------------|------|----------|
| `config.php` | Config | `index.php:5`, `contact.php:5` |
| `includes/variant.php` | Code | `index.php:14`, `contact.php:15` |
| `includes/mail.php` | Code | `index.php:6`, `contact.php:6` |
| `includes/head.php` | Code | all pages |
| `includes/footer.php` | Code | all pages |
| `assets/css/styles.css` | Static asset | `head.php:20` |
| `$_SESSION` | Runtime state | `head.php:7-12`, `index.php:23,28` |

## Change Guidance

- **Adding a page:** create `*.php`, set `$page_title`/`$current_page`, include
  head/footer. Add to nav in `head.php` if needed.
- **Adding nav item:** add `<li>` to `head.php:29-33` nav list
- **Changing meta robots:** set `$meta_robots` before including head.php
  (see `KC-dds-ref/index.php:16`)
- **Code gate code:** change "DrClemans" in `index.php:22`
- **Test coverage:** 10 tests cover page rendering (200 status, content, errors)
