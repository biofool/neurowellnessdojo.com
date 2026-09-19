# Component: mail

**Path:** `includes/mail.php` (49 lines)
**Revision:** d77a399

## Responsibility

Thin wrapper around PHP `mail()` with consistent headers. Also provides
throttled visit-notification emails (one per session per page).

## Interfaces

- `nwd_send_mail(array $config, string $to, string $subject, string $body, array $extraHeaders = []): bool`
- `nwd_notify_visit(array $config, string $page): void`

## Dependencies

| Dependency | Type | Evidence |
|------------|------|----------|
| `$config['mail_from']` | Config | `mail.php:11` |
| `$config['mail_from_name']` | Config | `mail.php:11` |
| `$config['intake_email']` | Config | `mail.php:47` |
| PHP `mail()` | Runtime (sendmail) | `mail.php:17` |
| `$_SESSION` | Runtime state | `mail.php:26-31` |
| `$_SERVER` | Runtime state | `mail.php:34-37` |

## Consumers

| Consumer | Functions Used |
|----------|----------------|
| `index.php` | `nwd_notify_visit()` |
| `contact.php` | `nwd_notify_visit()` |
| `submit.php` | `nwd_send_mail()` |

## Email Headers (nwd_send_mail)

```
From: {mail_from_name} <{mail_from}>
X-Mailer: PHP/{phpversion}
Content-Type: text/plain; charset=UTF-8
{extraHeaders}
```

**Evidence:** OBSERVED — `mail.php:10-17`.

## Visit Notification (nwd_notify_visit)

- Throttled: one email per session per page (`$_SESSION['notified_<page>']`)
- Includes: URL, referrer, IP address, timestamp, user-agent
- Uses `@` error suppression (line 47) — mail failures are silent
- Starts session if not already active

**Evidence:** OBSERVED — `mail.php:24-48`.

## Failure Paths

| Failure | Behavior |
|---------|----------|
| `mail()` returns false | `nwd_send_mail` returns false; caller decides action |
| `nwd_notify_visit` mail fails | `@` suppressed, session flag still set |
| sendmail not found | PHP warning (not suppressed in `nwd_send_mail`); `@` in `nwd_notify_visit` |

## Change Guidance

- **Switching to SMTP:** replace `mail()` call in `nwd_send_mail` with PHPMailer
- **Adding HTML email:** change Content-Type header, update body format
- **Removing visit notifications:** remove `nwd_notify_visit()` calls from pages
- **Test coverage:** no direct tests; `nwd_notify_visit` exercised by page render tests
