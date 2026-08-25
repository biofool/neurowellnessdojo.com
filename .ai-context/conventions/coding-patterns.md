# Coding Patterns

## PHP Conventions

### strict_types — strongly recurring (4 files)
`declare(strict_types=1);` at top of files with logic:
- `index.php:2`, `submit.php:2`, `contact.php:2`, `KC-dds-ref/index.php:2`
- NOT present in: `privacy.php`, `thank-you.php`, `404.php`, `includes/head.php`,
  `includes/footer.php` (static content / no function definitions)

### Function naming — strongly recurring (4 functions)
All shared functions prefixed with `nwd_`:
- `nwd_variant()`, `nwd_terms()` — `includes/variant.php`
- `nwd_send_mail()`, `nwd_notify_visit()` — `includes/mail.php`

### Output escaping — strongly recurring
All dynamic HTML output uses `htmlspecialchars($val, ENT_QUOTES, 'UTF-8')`:
- `index.php:49,62,67,147,148` — variant terms, CSRF token
- `contact.php:37,38,63` — CSRF token, variant, email
- `KC-dds-ref/index.php:54,59,67,68,69` — variant terms, CSRF, referral
- `head.php:18,19` — meta_robots, page_title

### Include pattern — strongly recurring
Pages use `require __DIR__ . '/config.php'` and `require __DIR__ . '/includes/...'`:
- All pages with logic follow: config → mail → (maintenance check) → variant → head → content → footer
- Subdirectory pages use `__DIR__ . '/../config.php'` (KC-dds-ref)

### Config access — strongly recurring
Config is a PHP array returned by `require`:
```php
$config = require __DIR__ . '/config.php';
```
Accessed as `$config['key']` throughout. No config class or env var parsing.

### Session management — strongly recurring
- `session_start()` called in `head.php:7-9` (if not already active)
- `submit.php:8` calls `session_start()` directly (no head.php include)
- `mail.php:26-28` calls `session_start()` if not active

### Error handling — weak pattern (2 instances)
- `@` error suppression used for mail() calls: `mail.php:47`, `submit.php:73,95`
- No logging mechanism — errors are silently suppressed
- AGENTS.md states "Never fail silently" but `@` suppression is used (tension)

### Form structure — strongly recurring
Intake forms share this structure:
```html
<form action="/submit.php" method="post" novalidate>
  <input type="hidden" name="csrf" value="...">
  <input type="hidden" name="variant" value="...">
  <!-- optional: <input type="hidden" name="referral" value="..."> -->
  <!-- optional: honeypot div.hp -->
  <div class="field"> name </div>
  <div class="field"> email </div>
  <div class="field"> message </div>
  <p class="reassurance">...</p>
  <button type="submit" class="button">Send</button>
</form>
```

### CSS — single file convention
- All styles in `assets/css/styles.css` (405 lines)
- CSS custom properties in `:root` for theming
- No preprocessor, no CSS modules, no inline styles (one exception: `KC-dds-ref/index.php:87`)

### Test convention
- Python/pytest integration tests in `tests/test_pages.py`
- Tests start a PHP built-in server, make HTTP requests with `requests` library
- Test names: `test_<page>_<behavior>` (e.g., `test_home_200`, `test_submit_rejects_get`)
- PHP error markers checked: Fatal, Parse, Warning, Notice, Deprecated
