# Architecture Decisions

## ADR-001: Plain PHP, no framework

**Status:** OBSERVED
**Evidence:** No `composer.json`, no framework files, `declare(strict_types=1)`
in PHP files, CLAUDE.md:9 "no build step, no npm, no framework"
**Rationale:** DECLARED in README.md:5 — "Drop it on any host that runs PHP 7.4
or later." Shared hosting compatibility is the primary constraint.

## ADR-002: Server-side A/B testing (no JavaScript)

**Status:** OBSERVED
**Evidence:** `includes/variant.php` — variant assigned via PHP `mt_rand()`,
stored in cookie. No JS files in repo. README.md:71 "No client-side JavaScript
involved."
**Rationale:** DECLARED in TechnicalMarketingReadMe.md:57 — "Variant selection
happens server-side with cookie persistence, so the variant is consistent
across visits and page loads."

## ADR-003: Email as source of truth, Sheets as secondary

**Status:** OBSERVED
**Evidence:** `submit.php:76` comment — "Failures here don't block — the email
is the source of truth." Sheets webhook is `@`-suppressed with 5s timeout.
**Rationale:** INFERRED — email is more reliable than a webhook on shared hosting;
Sheets provides structured tracking but is not critical path.

## ADR-004: Session-based CSRF (not per-request)

**Status:** OBSERVED
**Evidence:** `head.php:10-12` — CSRF token generated once per session if
missing. `submit.php:101` — burned after success.
**Rationale:** UNKNOWN — no documentation. INFERRED: simpler than per-request
tokens for a multi-form site; acceptable for low-volume landing page.

## ADR-005: No database

**Status:** OBSERVED
**Evidence:** No DB connection code, no PDO/MySQLi, no migration files.
TechnicalMarketingReadMe.md:108 — "No database — All state is in sessions,
cookies, and Google Sheets."
**Rationale:** DECLARED — shared hosting simplicity, no query/reporting needed.

## ADR-006: Code gate for referral access

**Status:** OBSERVED
**Evidence:** `index.php:21-28` — session-based code gate ("DrClemans").
Git commit 1773db3: "Gate Dr. Clemans referral info behind session code."
**Rationale:** INFERRED — controls who sees full content without user accounts.
TechnicalMarketingReadMe.md:113 acknowledges "not a real auth system."

## ADR-007: Separate referral page (KC-dds-ref)

**Status:** OBSERVED
**Evidence:** `KC-dds-ref/index.php` — dedicated page with `noindex,nofollow`,
referral hidden field, different copy (no "dental anxiety" language).
Git commit d77a399 added this page.
**Rationale:** INFERRED — dentist-specific landing page that doesn't expose
the dental anxiety framing; noindex to keep it unlisted.

## ADR-008: Dark theme adapted from Quantum Aikido

**Status:** OBSERVED
**Evidence:** `styles.css:1` comment — "dark theme, adapted from Quantum Aikido"
Git commit 905dbf7: "Adopt Quantum Aikido dark theme"
**Rationale:** INFERRED — reuse existing design system from sibling project.
