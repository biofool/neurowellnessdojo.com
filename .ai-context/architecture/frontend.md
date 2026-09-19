# Frontend Architecture

## Page Inventory

| Page | Path | Code Gate | A/B Variant | Intake Form | Meta Robots |
|------|------|-----------|-------------|-------------|-------------|
| Home (locked) | `index.php` | Yes ("DrClemans") | Yes | No (shows code gate) | `index,follow` |
| Home (unlocked) | `index.php` | Yes (unlocked) | Yes | Yes | `index,follow` |
| Contact | `contact.php` | No | Yes | Yes | `index,follow` (default) |
| Privacy | `privacy.php` | No | No | No | `index,follow` (default) |
| Thank you | `thank-you.php` | No | No | No | `index,follow` (default) |
| 404 | `404.php` | No | No | No | `index,follow` (default) |

**Evidence:** OBSERVED — `index.php:21-28` (code gate),
`includes/head.php:18` (meta robots output).

## Rendering Pipeline

All pages follow the same include pattern:

```
1. $config = require __DIR__ . '/config.php';     // Load config
2. require __DIR__ . '/includes/mail.php';         // Load mail functions
3. (optional) maintenance check → 503 exit
4. require __DIR__ . '/includes/variant.php';      // Load variant functions
5. $variant = nwd_variant($config);                // Get/set A/B variant
6. $t = nwd_terms($variant);                       // Get variant word swaps
7. $page_title = '...';
8. include __DIR__ . '/includes/head.php';         // session_start, CSRF, <head>, nav
9. ... page-specific HTML with htmlspecialchars() ...
10. include __DIR__ . '/includes/footer.php';      // footer + closing tags
```

**Evidence:** OBSERVED — consistent pattern across `index.php`, `contact.php`.
`privacy.php`, `thank-you.php`, `404.php` are simpler
(no variant/mail include).

## Shared Includes Detail

### `includes/head.php` (38 lines)
- Starts session if not already active
- Generates CSRF token (`bin2hex(random_bytes(32))`) if missing
- Outputs `<!doctype html>`, `<head>` with charset, viewport, robots meta, title
- Links stylesheet `/assets/css/styles.css`
- Renders header with nav (Home, Contact, Privacy) and `aria-current` on active page
- Expects `$page_title` and `$current_page` to be set before include

### `includes/footer.php` (17 lines)
- Closes `</main>`, renders `<footer>` with Privacy link and contact email
- Hardcoded email: `coach@neurowellnessdojo.com` (line 9)
- Outputs `© {year} Neuro Wellness Dojo`

### `includes/variant.php` (48 lines)
- `nwd_variant(array $config): string` — returns 'A' or 'B'
- `nwd_terms(string $variant): array` — returns 5 word-swap keys

### `includes/mail.php` (49 lines)
- `nwd_send_mail(array $config, string $to, string $subject, string $body, array $extraHeaders = []): bool`
- `nwd_notify_visit(array $config, string $page): void`

## Styling

- Single file: `assets/css/styles.css` (405 lines)
- Dark theme adapted from Quantum Aikido (line 1 comment)
- CSS custom properties (`:root` variables) for colors
- Responsive: `@media (max-width: 768px)` breakpoint
- Accessibility: skip-link, focus-visible styles, `prefers-reduced-motion`
- Honeypot hidden via `.hp { position: absolute; left: -9999px; }`

**Evidence:** OBSERVED — `styles.css` lines 1-405.

## Forms

Two intake form variants exist, both POST to `/submit.php`:

| Form Location | Honeypot | Referral Field | Reassurance Text |
|---------------|----------|----------------|-------------------|
| `index.php` (unlocked) | Yes | No | "Dr. Clemans will never see what you wrote." |
| `contact.php` | No | No | "Your comments are private between you and your coach." |

**Evidence:** OBSERVED — `index.php:150-153` (honeypot),
`contact.php:55` (no honeypot).
