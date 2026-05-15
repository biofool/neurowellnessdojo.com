<?php
// Copy this file to config.php and fill in the values below.
// config.php is gitignored / kept off version control.

return [

    // Where intake form submissions are emailed.
    // Default: the alias on the site domain (forward this to your working inbox).
    'intake_email' => 'coach@neurowellnessdojo.com',

    // The "From" address on outgoing mail.
    // Most shared hosts require this to be on the same domain to avoid spam filters.
    'mail_from' => 'noreply@neurowellnessdojo.com',
    'mail_from_name' => 'Neuro Wellness Dojo',

    // Google Apps Script web app URL for writing intake submissions to a Sheet.
    // Setup instructions are in README.md. Leave empty to skip Sheet logging.
    'sheets_webhook_url' => '',

    // Site URL (used for absolute links in emails). No trailing slash.
    'site_url' => 'https://neurowellnessdojo.com',

    // A/B test variant cookie name and lifetime (in seconds).
    'variant_cookie' => 'nwd_variant',
    'variant_cookie_ttl' => 60 * 60 * 24 * 365, // one year

    // Set true while building. Hides the live site behind a notice.
    'maintenance' => false,
];
