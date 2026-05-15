<?php
declare(strict_types=1);

$config = require __DIR__ . '/config.php';
require __DIR__ . '/includes/variant.php';
require __DIR__ . '/includes/mail.php';

session_start();

// Only POST.
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Allow: POST');
    exit('Method not allowed.');
}

// CSRF check.
if (empty($_POST['csrf']) || empty($_SESSION['csrf']) || !hash_equals($_SESSION['csrf'], (string)$_POST['csrf'])) {
    http_response_code(400);
    exit('Invalid request.');
}

// Honeypot. Silent success for bots — no clue we caught them.
if (!empty($_POST['website'])) {
    header('Location: /thank-you.php');
    exit;
}

// Light rate limit. One submission per 60 seconds per session.
if (!empty($_SESSION['last_submit']) && (time() - (int)$_SESSION['last_submit']) < 60) {
    http_response_code(429);
    exit('Please wait a moment before submitting again.');
}

// Pull and validate fields.
$name    = trim((string)($_POST['name']    ?? ''));
$email   = trim((string)($_POST['email']   ?? ''));
$message = trim((string)($_POST['message'] ?? ''));
$variant = (string)($_POST['variant'] ?? '');
$variant = in_array($variant, ['A', 'B'], true) ? $variant : 'unknown';

$errors = [];
if ($name === '' || mb_strlen($name) > 120) {
    $errors[] = 'name';
}
if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || mb_strlen($email) > 200) {
    $errors[] = 'email';
}
if (mb_strlen($message) > 2000) {
    $errors[] = 'message';
}

if (!empty($errors)) {
    http_response_code(400);
    echo "Something didn't look right with: " . implode(', ', $errors) . ". <a href='/'>Try again</a>.";
    exit;
}

// Send to Kenneth.
$subject  = 'Neuro Wellness Dojo — new intake';
$body     = "New intake submission.\n\n"
          . "Name:    {$name}\n"
          . "Email:   {$email}\n"
          . "Variant: {$variant}\n"
          . "When:    " . date('c') . "\n\n"
          . "What's bringing them here:\n"
          . "{$message}\n";

$extraHeaders = ['Reply-To: ' . $email];
$sent = @nwd_send_mail($config, $config['intake_email'], $subject, $body, $extraHeaders);

// Also POST to Google Sheets webhook, if configured.
// Failures here don't block — the email is the source of truth.
if (!empty($config['sheets_webhook_url'])) {
    $payload = json_encode([
        'name'      => $name,
        'email'     => $email,
        'message'   => $message,
        'variant'   => $variant,
        'timestamp' => date('c'),
    ]);
    $ctx = stream_context_create([
        'http' => [
            'method'        => 'POST',
            'header'        => "Content-Type: application/json\r\n",
            'content'       => $payload,
            'timeout'       => 5,
            'ignore_errors' => true,
        ],
    ]);
    @file_get_contents($config['sheets_webhook_url'], false, $ctx);
}

$_SESSION['last_submit'] = time();

// Burn the CSRF token so the same form can't be replayed.
unset($_SESSION['csrf']);

header('Location: /thank-you.php');
exit;
