# Technical Marketing Summary — neurowellnessdojo.com

## One-Line Positioning

A referral landing page for a nervous-system self-regulation coaching practice
that helps dental-anxiety patients learn practical relaxation skills — with
A/B testing, intake forms, and Google Sheets integration.

## Target Users / Personas

- **Dental patients with anxiety** — Patients referred by their dentist (Dr.
  Clemans) who need practical relaxation techniques for use in the dental
  chair, delivered via one-on-one video sessions.
- **Referring dentists** — Dental professionals who refer patients to the
  coaching practice via a gated referral page with an access code.
- **The coach / practice operator** — Kenneth Kron, who receives intake
  notifications, manages submissions in Google Sheets, and follows up with
  prospective clients.

## Key Features (Grounded in Code)

- **A/B test variants** — Server-side variant selection (A: "somatic
  practice" vs. B: "mind/body") with sticky cookie persistence (1-year TTL).
  Word swaps for modality, discipline, and opening paragraph text
  (`includes/variant.php`).
- **Intake form with CSRF + honeypot** — Contact form with CSRF token
  protection, honeypot field for bot detection, and light rate limiting (one
  submission per 60 seconds per session) (`submit.php`).
- **Dual delivery: email + Google Sheets** — Form submissions are emailed to
  the intake address and optionally posted to a Google Sheets webhook via
  Apps Script (`submit.php`, `apps-script.gs`).
- **Referral code gate** — Dr. Clemans's patients access the site via a code
  gate ("DrClemans") that unlocks the full landing page content
  (`index.php`).
- **Visit notifications** — Throttled email notifications when a visitor
  lands on a page (one per session per page), including IP, user agent, and
  referrer (`includes/mail.php`).
- **Maintenance mode** — Configurable maintenance flag that returns 503 and
  hides the site behind a notice (`config.example.php`, all pages).
- **Privacy policy** — GDPR-aware privacy policy page detailing what data is
  collected and how it's used (`privacy.php`).
- **SEO basics** — `robots.txt`, `sitemap.xml`, per-page meta robots, and
  semantic HTML (`robots.txt`, `sitemap.xml`, `includes/head.php`).
- **Accessibility** — Skip links, ARIA labels, semantic HTML, and
  keyboard-navigation support (`includes/head.php`, `assets/css/styles.css`).
- **Google Apps Script integration** — Ready-to-deploy Apps Script that
  appends intake submissions to a Google Sheet with timestamp, name, email,
  message, and variant (`apps-script.gs`).
- **KC-DDS referral page** — Dedicated referral page for Dr. Clemans's
  practice with `noindex,nofollow` meta robots (`KC-dds-ref/index.php`).

## Technical Differentiators

- **Zero-dependency PHP** — Plain PHP 7.4+ with no Composer, no framework,
  no build step. Drop it on any host that runs PHP.
- **Server-side A/B testing** — Variant selection happens server-side with
  cookie persistence, so the variant is consistent across visits and
  page loads. No JavaScript required for variant assignment.
- **Dual-channel intake** — Submissions go to both email and Google Sheets,
  providing redundancy and a structured record without a database.
- **Security by default** — CSRF tokens, honeypot fields, rate limiting, and
  `.htaccess` rules that deny access to config and includes.
- **Referral code gate** — A simple session-based access code gate controls
  who sees the full landing page, enabling referral-only access without
  user accounts.

## Use Cases

- **Dental anxiety coaching referral** — A dentist refers a patient to
  neurowellnessdojo.com. The patient enters the access code, reads about the
  service, and submits an intake form to request a free 20-minute session.
- **A/B testing landing page copy** — The coach tests whether "somatic
  practice" or "mind/body" framing resonates more with visitors, with
  variant tracked through to the submission.
- **Intake pipeline** — Submissions are emailed to the coach and logged in
  Google Sheets for follow-up tracking, with variant data for analyzing
  which copy converts better.

## Benefits / Value Proposition

- **No technical overhead** — Plain PHP on shared hosting. No framework, no
  database, no build step. Setup in minutes.
- **Data-driven copy optimization** — Server-side A/B testing with variant
  tracking through to submission lets the coach optimize messaging without
  third-party tools.
- **Redundant intake pipeline** — Email + Google Sheets dual delivery
  ensures no submission is lost, even if one channel fails.
- **Referral-gated access** — The access code gate ensures only referred
  patients see the full content, maintaining a controlled intake flow.
- **Privacy-conscious** — CSRF, honeypot, rate limiting, and a clear privacy
  policy build trust with anxious patients.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | PHP 7.4+ (plain PHP, no framework) |
| Styling | Single CSS file (`assets/css/styles.css`) |
| A/B testing | Server-side PHP with cookie persistence |
| Forms | PHP `mail()` + Google Apps Script webhook |
| Data storage | Google Sheets (via Apps Script) |
| Security | CSRF tokens, honeypot, rate limiting, `.htaccess` |
| SEO | `robots.txt`, `sitemap.xml`, per-page meta robots |
| Hosting | Any PHP 7.4+ host (shared hosting compatible) |

## Known Limitations

- **No database** — All state is in sessions, cookies, and Google Sheets.
  No local query or reporting capability.
- **Single coach** — The site is designed for a single coaching practice
  with one intake email address.
- **No authentication system** — The access code gate is a simple session
  flag, not a real auth system. It's not secure against determined access.
- **No analytics** — Visit notifications are emailed but there's no
  analytics dashboard or conversion tracking built in.
- **A/B test reporting is manual** — Variant is tracked in the Sheet, but
  there's no built-in reporting to compare conversion rates between
  variants.
- **PHP `mail()` dependency** — Relies on the host's `mail()` function,
  which may be restricted on some shared hosts.
