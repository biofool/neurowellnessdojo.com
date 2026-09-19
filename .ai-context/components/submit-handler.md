# Component: submit-handler

**Path:** `submit.php` (104 lines)
**Revision:** d77a399

## Responsibility

Single endpoint for all intake form submissions. Enforces security controls,
validates input, sends email notification, optionally logs to Google Sheets,
and redirects to thank-you page.

## Interfaces

- **Input:** HTTP POST to `/submit.php`
  - Required: `csrf`, `name`, `email`
  - Optional: `message`, `variant`, `referral`, `website` (honeypot)
- **Output:** HTTP 302 redirect to `/thank-you.php` on success
- **Error outputs:**
  - 405 (method not allowed) for non-POST
  - 400 (invalid request) for CSRF failure or validation errors
  - 429 (too many requests) for rate limit
  - 302 to thank-you for honeypot trigger (silent success)

## Dependencies

| Dependency | Type | Evidence |
|------------|------|----------|
| `config.php` | Config (require) | `submit.php:4` |
| `includes/variant.php` | Code (require) | `submit.php:5` |
| `includes/mail.php` | Code (require) | `submit.php:6` |
| PHP `mail()` | Runtime (sendmail) | `submit.php:73` |
| Google Sheets webhook | External HTTP (optional) | `submit.php:77-95` |
| `$_SESSION` | Runtime state | `submit.php:8,18,30,98,101` |

## Consumers

| Consumer | How |
|----------|-----|
| `index.php` (unlocked) | Form action="/submit.php" |
| `contact.php` | Form action="/submit.php" |

## Security Controls (in order)

1. **Method check** — reject non-POST with 405 + `Allow: POST` header
2. **CSRF validation** — `hash_equals($_SESSION['csrf'], $_POST['csrf'])`
3. **Honeypot** — if `$_POST['website']` non-empty → silent redirect (no email)
4. **Rate limit** — if `$_SESSION['last_submit']` < 60s ago → 429
5. **Field validation:**
   - `name`: non-empty, ≤120 chars
   - `email`: non-empty, valid (`FILTER_VALIDATE_EMAIL`), ≤200 chars
   - `message`: ≤2000 chars (optional)
   - `variant`: must be 'A' or 'B', else 'unknown'
   - `referral`: sanitized via `preg_replace('/[^A-Za-z0-9_\-]/', '', ...)`
6. **CSRF burn** — `unset($_SESSION['csrf'])` after success

**Evidence:** OBSERVED — `submit.php` lines 10-101.

## Failure Paths

| Failure | Response | Email Sent? | Sheet Logged? |
|---------|----------|-------------|---------------|
| Non-POST method | 405 | No | No |
| Missing/invalid CSRF | 400 | No | No |
| Honeypot triggered | 302 → thank-you | No | No |
| Rate limited | 429 | No | No |
| Validation error | 400 with field names | No | No |
| `mail()` fails | `@` suppressed, still redirects | No | Yes (if configured) |
| Sheets webhook fails | `@` suppressed, still redirects | Yes | No |

**Note:** `nwd_send_mail()` return value is captured in `$sent` (line 73) but
**never checked** — the redirect happens regardless. The Sheets webhook is
also `@`-suppressed. Email is stated as source of truth (line 76 comment).

## Change Guidance

- **Adding a new form field:** add to validation block (lines 35-53), add to
  email body (lines 62-70), add to Sheets payload (lines 78-85)
- **Changing rate limit:** modify the `60` on line 30
- **Adding a new security control:** insert between honeypot and rate limit
- **Swapping mail() for SMTP:** replace `nwd_send_mail()` call with PHPMailer
- **Test coverage:** `tests/test_pages.py` has 4 tests for submit.php security
