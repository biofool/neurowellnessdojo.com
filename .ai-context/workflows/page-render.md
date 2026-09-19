# Workflow: Page Render

**Revision:** d77a399

## Entry Point

HTTP GET to any page: `/`, `/contact.php`, `/privacy.php`, `/thank-you.php`,
`/404.php`

## Execution Path (index.php as example)

1. **Load config** — `index.php:5`
   - `$config = require __DIR__ . '/config.php';`

2. **Load mail functions** — `index.php:6`
   - `require __DIR__ . '/includes/mail.php';`

3. **Maintenance check** — `index.php:8-12`
   - If `$config['maintenance']` is truthy → 503 + "Site temporarily unavailable." + exit

4. **Load variant functions** — `index.php:14`
   - `require __DIR__ . '/includes/variant.php';`

5. **Set page metadata** — `index.php:16-17`
   - `$page_title = 'Neuro Wellness Dojo';`
   - `include __DIR__ . '/includes/head.php';`

6. **head.php executes:**
   - Start session if not active (`head.php:7-9`)
   - Generate CSRF token if missing (`head.php:10-12`)
   - Output `<!doctype html>`, `<head>`, `<header>` with nav (`head.php:13-37`)

7. **Code gate check** — `index.php:20-28`
   - If POST with `access_code`:
     - Match "DrClemans" → `$_SESSION['clemans_unlocked'] = true`
     - No match → `$code_error = true`
   - `$unlocked = !empty($_SESSION['clemans_unlocked']);`

8. **Visit notification** — `index.php:30`
   - `nwd_notify_visit($config, 'home')` — sends email if first visit in session

9. **Variant assignment** — `index.php:31-32`
   - `$variant = nwd_variant($config);` — read/set cookie
   - `$t = nwd_terms($variant);` — get word swaps

10. **Render content** — `index.php:34-107` (locked) or `index.php:109-198` (unlocked)
    - HTML with `htmlspecialchars($t['...'], ENT_QUOTES, 'UTF-8')` for variant text
    - Intake form with CSRF hidden field, variant hidden field, honeypot (unlocked only)

11. **Footer** — `index.php:103` or `index.php:198`
    - `include __DIR__ . '/includes/footer.php';`

## Variation by Page

| Page | Config | Mail | Variant | Maintenance | Code Gate |
|------|--------|------|---------|-------------|-----------|
| index.php | Yes | Yes | Yes | Yes | Yes |
| contact.php | Yes | Yes | Yes | Yes | No |
| privacy.php | No | No | No | No | No |
| thank-you.php | No | No | No | No | No |
| 404.php | No | No | No | No | No |

## Evidence

| Step | File:Lines | Test |
|------|-----------|------|
| Maintenance check | `index.php:8-12` | (no test — maintenance=false in config) |
| head.php session/CSRF | `head.php:7-12` | `test_contact_has_intake_form` (CSRF present) |
| Code gate (locked) | `index.php:20-28` | `test_home_shows_code_gate_when_locked`, `test_home_unlocks_with_correct_code`, `test_home_shows_error_on_wrong_code` |
| Variant assignment | `variant.php:5-28` | (indirectly via page render tests) |
| Page render | all pages | `test_home_200`, `test_contact_200`, `test_privacy_200`, `test_thankyou_200`, `test_404_page_returns_404` |

## Failure Paths

| Failure | Behavior |
|---------|----------|
| config.php missing | PHP fatal error (require fails) |
| maintenance=true | 503 + exit |
| Session start fails | PHP warning, CSRF not set → form submission will fail |
| Wrong access code | Page re-renders locked view with error message |

## Change Guidance

- New pages: follow the include pattern (config → mail → variant → head → content → footer)
- Static pages (privacy, thank-you, 404) can skip config/mail/variant
- `$meta_robots` must be set before including head.php (default is `index,follow`)
