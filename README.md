# Neuro Wellness Dojo

The referral landing page for Dr. Clemans's patients.

Plain PHP. No build step. No npm. Drop it on any host that runs PHP 7.4 or later.

## What's in the box

```
.
├── index.php             # The landing page (A/B variant chosen server-side)
├── submit.php            # Form handler — emails coach@, optionally posts to a Google Sheet
├── thank-you.php         # Post-submission confirmation
├── privacy.php           # Privacy policy
├── config.example.php    # Copy this to config.php and fill in
├── apps-script.gs        # Google Apps Script for the Sheet webhook
├── .htaccess             # Apache: denies access to config + includes
├── assets/css/styles.css # Single stylesheet
└── includes/
    ├── head.php
    ├── footer.php
    └── variant.php       # A/B logic and word swaps
```

## Setup

### 1. Configure

Copy the config template and fill it in:

```
cp config.example.php config.php
```

Open `config.php`. Set `intake_email` to wherever you want intake submissions sent (default: `coach@neurowellnessdojo.com`). Set `mail_from` to a noreply alias on the same domain — shared hosts reject mail with a mismatched From.

### 2. Upload

SFTP / rsync / git pull the directory to your webroot (or a subdirectory if you're running it under another site).

```
rsync -av --exclude='.git' ./ user@host:/var/www/neurowellnessdojo/
```

### 3. Set up the Sheet (optional but recommended)

Email is the source of truth. The Sheet is for tracking conversion by A/B variant.

1. New Google Sheet. First row headers: `timestamp | name | email | message | variant`.
2. Extensions → Apps Script. Paste in the contents of `apps-script.gs`.
3. Deploy → New deployment → Web app.
   - Execute as: Me
   - Who has access: Anyone
4. Copy the deployment URL. Paste into `config.php` as `sheets_webhook_url`.

The "Anyone" access only lets external requests *write* to the script — it doesn't expose the Sheet contents.

### 4. Email forwarding

`coach@neurowellnessdojo.com` should forward to Kenneth's working inbox. Most registrars and hosts offer a free forwarding alias. Set up `noreply@neurowellnessdojo.com` as a valid sender too, so outgoing mail doesn't get spam-filtered.

### 5. SSL

Once HTTPS works, uncomment the redirect block in `.htaccess`.

## How the A/B test works

- First visit: server flips a coin, sets cookie `nwd_variant` to `A` or `B`, valid for a year.
- Returning visit: cookie sticks, same version shown.
- The form submission records which variant the visitor was on, so you can see in the Sheet which variant converts.
- No client-side JavaScript involved.

Variant A uses "somatic" language. Variant B uses "mind/body" language. The only sections that differ are "What this is," "Your coach," and "The practice." Everything else is identical.

To stop the test and lock to one variant: set `nwd_variant` cookie manually in your browser, or hardcode the return value in `includes/variant.php`.

## Notes & gotchas

- **PHP `mail()`** uses sendmail under the hood. On most shared hosts this works for low volume. If deliverability becomes a problem, switch to SMTP via PHPMailer — the `submit.php` is small enough to swap the send block easily.
- **Rate limiting** is session-based: one submission per 60 seconds per session. Stops drive-by spam but doesn't stop a determined attacker.
- **Honeypot field** in the form catches dumb bots. Real users never see it; bots filling every field will trip it and get a silent fake-success redirect.
- **CSRF token** stored in session, regenerated per form load, burned on submit.
- **`noindex,nofollow`** is set in the page head — this is a private referral page, not for search engines.
- **No external JS** loads. The only third-party request is the Lora webfont from Google. To run fully zero-third-party, self-host the font and edit `includes/head.php`.

## Privacy policy

Two placeholders remain in `privacy.php`:

1. The effective date (`[SET ON LAUNCH]`) — replace with the date you go live.
2. The optional mailing address at the bottom — CCPA compliance is cleaner with one but it's not strictly required.

## Things to do before launch

- [ ] Fill in `config.php`
- [ ] Set up `coach@` and `noreply@` aliases
- [ ] Create the Sheet and deploy the Apps Script
- [ ] Paste the webhook URL into `config.php`
- [ ] Install SSL, uncomment the HTTPS redirect in `.htaccess`
- [ ] Set the effective date in `privacy.php`
- [ ] Send yourself an intake submission to verify email + Sheet write
- [ ] Clear your own cookies and load the page from two browsers to confirm A and B both render

## Things to think about before sharing the URL with Dr. Clemans

- [ ] Confirm the lineage / credentials text on page reads correctly with Richard
- [ ] Confirm Kenneth's bio line with Kenneth
- [ ] Confirm Dr. Clemans is comfortable being named on the page
- [ ] Confirm the no-AI-retention line is accurate given your actual Zoom / WhatsApp setup
