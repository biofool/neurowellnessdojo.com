# Workflow: Intake Submission

**Revision:** d77a399

## Entry Point

HTTP POST to `/submit.php` from any intake form:
- `index.php` (unlocked view, form at line 146)
- `contact.php` (form at line 36)

## Execution Path

1. **Load dependencies** — `submit.php:4-6`
   - `require config.php` → `$config` array
   - `require includes/variant.php` → functions (not called)
   - `require includes/mail.php` → `nwd_send_mail()`

2. **Start session** — `submit.php:8`
   - `session_start()` (no output yet)

3. **Method check** — `submit.php:11-15`
   - If not POST → 405 + `Allow: POST` header + exit

4. **CSRF validation** — `submit.php:18-21`
   - Compare `$_POST['csrf']` with `$_SESSION['csrf']` via `hash_equals()`
   - If mismatch → 400 + exit

5. **Honeypot check** — `submit.php:24-27`
   - If `$_POST['website']` non-empty → 302 redirect to `/thank-you.php` + exit
   - (Silent success — bot gets no indication of detection)

6. **Rate limit** — `submit.php:30-33`
   - If `$_SESSION['last_submit']` exists and < 60s ago → 429 + exit

7. **Field extraction & validation** — `submit.php:36-59`
   - `name`: trim, non-empty, ≤120 chars
   - `email`: trim, non-empty, `FILTER_VALIDATE_EMAIL`, ≤200 chars
   - `message`: trim, ≤2000 chars (optional)
   - `variant`: must be 'A' or 'B', else 'unknown'
   - `referral`: sanitized via regex
   - If any error → 400 with field names + exit

8. **Send email** — `submit.php:62-73`
   - Build plain-text body with name, email, variant, referral, timestamp, message
   - `nwd_send_mail($config, $config['intake_email'], $subject, $body, ['Reply-To: ' . $email])`
   - Return value captured in `$sent` but **not checked**

9. **Post to Google Sheets** — `submit.php:77-95`
   - If `sheets_webhook_url` configured:
   - Build JSON payload (name, email, message, variant, referral, timestamp)
   - `file_get_contents()` with `stream_context_create()` (POST, 5s timeout)
   - `@` error suppression — failures don't block

10. **Record submission** — `submit.php:98`
    - `$_SESSION['last_submit'] = time()`

11. **Burn CSRF token** — `submit.php:101`
    - `unset($_SESSION['csrf'])`

12. **Redirect** — `submit.php:103-104`
    - `header('Location: /thank-you.php')` + exit

## Evidence

| Step | File:Lines | Test |
|------|-----------|------|
| Method check | `submit.php:11-15` | `test_submit_rejects_get` |
| CSRF validation | `submit.php:18-21` | `test_submit_rejects_missing_csrf`, `test_submit_rejects_wrong_csrf` |
| Honeypot | `submit.php:24-27` | `test_honeypot_gives_silent_redirect` |
| Rate limit | `submit.php:30-33` | (no test) |
| Field validation | `submit.php:36-59` | (no test) |
| Email send | `submit.php:62-73` | (not tested — sendmail unavailable) |
| Sheets webhook | `submit.php:77-95` | (not tested — external service) |
| Redirect | `submit.php:103-104` | `test_honeypot_gives_silent_redirect` (302 check) |

## Failure Paths

| Failure | HTTP Status | User Sees | Side Effects |
|---------|-------------|-----------|--------------|
| Non-POST | 405 | "Method not allowed." | None |
| CSRF invalid | 400 | "Invalid request." | None |
| Honeypot | 302 | thank-you.php | None (silent) |
| Rate limited | 429 | "Please wait..." | None |
| Validation | 400 | Field names + retry link | None |
| mail() fails | 302 | thank-you.php | No email sent; Sheets may still log |
| Sheets fails | 302 | thank-you.php | Email sent; no Sheet row |
| Both fail | 302 | thank-you.php | No email, no Sheet row (data loss) |

## Change Guidance

- Adding fields: update validation (step 7), email body (step 8), Sheets
  payload (step 9), and `apps-script.gs` appendRow
- The `$sent` variable (line 73) is unused — if you need to handle mail
  failure, check it before the redirect
- CSRF token is burned after success — a second submission requires a new
  page load to regenerate the token
