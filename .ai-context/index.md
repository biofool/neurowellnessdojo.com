# Context Index — neurowellnessdojo.com

> **Revision:** d77a399 (master) | **Verified:** 2026-08-22 | **Analyzer:** Context Compiler v2
> **Staleness:** If the last commit hash differs from the revision above, re-run
> the compiler. Check `manifest.yaml` for the pass plan and coverage scope.

## System Shape

Plain PHP 7.4+ landing page for a dental-anxiety coaching practice. No
framework, no build step, no npm, no JavaScript, no database. Single
deployable unit on shared hosting (peec.biz). ~2K LOC across 45 files.

| Aspect | Value |
|--------|-------|
| Language | PHP 7.4+ (8.5.4 local), Python 3.14 (tests only) |
| Framework | None — plain PHP with `require` includes |
| Build | None — files served directly |
| Deploy | `./sync.sh --remote peec.biz` (rsync over SSH) |
| Tests | `pytest tests/` (19 tests, starts PHP built-in server) |
| Config | `config.php` (gitignored), copy from `config.example.php` |
| Data | Email via PHP `mail()` + optional Google Sheets webhook |

## Major Entry Points

| Entry | File | Responsibility |
|-------|------|----------------|
| Home (code-gated) | `index.php` | Landing page; referral code gate unlocks intake form |
| Contact | `contact.php` | Standalone intake form (no code gate) |
| Form handler | `submit.php` | CSRF, honeypot, rate-limit, email, Sheets webhook |
| Referral page | `KC-dds-ref/index.php` | Dentist-specific landing (noindex) with referral field |
| Privacy | `privacy.php` | Privacy policy (static content) |
| Thank you | `thank-you.php` | Post-submission confirmation |
| 404 | `404.php` | Error page (routed via .htaccess) |

## Shared Includes

| Include | Responsibility |
|---------|----------------|
| `includes/head.php` | `session_start`, CSRF token gen, HTML `<head>`, nav |
| `includes/variant.php` | A/B variant selection (`nwd_variant`, `nwd_terms`) |
| `includes/mail.php` | `nwd_send_mail`, `nwd_notify_visit` (throttled) |
| `includes/footer.php` | Footer + closing HTML tags |

## Navigation Path

1. **Start here** → `quickstart.md` for commands and boundaries
2. **Architecture** → `architecture/system-overview.md` for data flows
3. **Component detail** → `components/<name>.md` for responsibility/deps
4. **Workflows** → `workflows/<name>.md` for end-to-end request paths
5. **Change impact** → `change-impact/relationships.yaml` before editing
6. **Conventions** → `conventions/` for patterns and rules
7. **Tests** → `testing/test-map.yaml` for validation commands
8. **Debt** → `debt/register.yaml` for known risks
9. **Source** → actual `.php` files as primary evidence

## Highest-Risk Areas

1. **`submit.php`** — security controls (CSRF, honeypot, rate-limit, validation)
2. **`config.php`** — secrets (intake email, Sheets webhook URL); gitignored
3. **`includes/variant.php`** — A/B test logic; changing affects all pages
4. **`.htaccess`** — access control (denies config/includes); server-only
5. **`sync.sh`** — deployment script; 820 lines, inherited from another project
