# Security Conventions

## Security Controls Inventory

### CSRF Protection — strongly recurring
- **Generation:** `includes/head.php:10-12` — `bin2hex(random_bytes(32))` per session
- **Validation:** `submit.php:18` — `hash_equals()` timing-safe comparison
- **Burn:** `submit.php:101` — `unset($_SESSION['csrf'])` after success
- **Scope:** Per-session (not per-request); token reused across multiple forms in same session
- **Evidence:** OBSERVED

### Honeypot — strongly recurring (1 of 2 forms)
- **Field:** `website` (hidden via CSS `.hp` class, `aria-hidden="true"`)
- **Behavior:** If filled → 302 redirect to thank-you (silent success, no email)
- **Present in:** `index.php:150-153` (unlocked)
- **NOT present in:** `contact.php` (per git commit 1b20ec5: "Drop honeypot field from contact form")
- **Evidence:** OBSERVED

### Rate Limiting — weak pattern (1 instance)
- **Implementation:** `submit.php:30-33` — session-based, 60-second window
- **Scope:** Per-session, not per-IP — stops drive-by spam, not determined attackers
- **Evidence:** OBSERVED — README.md:80 acknowledges this limitation

### Email Validation — strongly recurring
- `filter_var($email, FILTER_VALIDATE_EMAIL)` — `submit.php:48`
- Length limits: name ≤120, email ≤200, message ≤2000
- Referral field sanitized: `preg_replace('/[^A-Za-z0-9_\-]/', '', $referral)` — `submit.php:42`

### Access Control — .htaccess (server-only)
- Denies direct access to `config.php` and `config.example.php` — `.htaccess:4-6`
- Denies direct access to `includes/` directory — `.htaccess:8-10`
- `Options -Indexes` — disables directory listing
- `ServerSignature Off` — hides Apache version
- **NOT enforced by `php -S`** (test environment) — noted in test docstring

### Code Gate — weak pattern (1 instance)
- `index.php:21-28` — session-based access code ("DrClemans")
- Simple `strcasecmp` comparison, not hashed
- Sets `$_SESSION['clemans_unlocked']` — persists for session
- Not a real auth system (per TechnicalMarketingReadMe.md:113)

### Cookie Security
- A/B variant cookie: HttpOnly, SameSite=Lax, Secure (if HTTPS) — `variant.php:15-25`
- No other cookies set by the application

### HTTPS
- `.htaccess:13-15` — active HTTPS redirect (RewriteRule)
- **Note:** CLAUDE.md states this is commented out — see conflicts.yaml CONFLICT-001

## Security Gaps (see debt/register.yaml)

- `@` error suppression on mail() and file_get_contents() — violates AGENTS.md "never fail silently"
- No input length validation on access_code POST field (`index.php:21-27`)
- Rate limit is session-based, not IP-based — bypassable by clearing cookies
- Code gate code is hardcoded in source (`index.php:22`) — visible in git
- No Content-Security-Policy or other security headers in `.htaccess`
- Sheets webhook URL sent via unencrypted HTTP if not HTTPS (depends on config value)
