<?php
declare(strict_types=1);

/**
 * Send mail via the local sendmail binary.
 * Wraps PHP's mail() with consistent From/Content-Type headers.
 */
function nwd_send_mail(array $config, string $to, string $subject, string $body, array $extraHeaders = []): bool
{
    $headers = [];
    $headers[] = 'From: ' . $config['mail_from_name'] . ' <' . $config['mail_from'] . '>';
    $headers[] = 'X-Mailer: PHP/' . phpversion();
    $headers[] = 'Content-Type: text/plain; charset=UTF-8';
    foreach ($extraHeaders as $h) {
        $headers[] = $h;
    }
    return mail($to, $subject, $body, implode("\r\n", $headers));
}

/**
 * Notify the intake email that a visitor landed on a given page.
 * Throttled to one notification per session per page.
 */
function nwd_notify_visit(array $config, string $page): void
{
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    $key = 'notified_' . $page;
    if (!empty($_SESSION[$key])) {
        return;
    }

    $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $ua = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
    $url = ($_SERVER['REQUEST_SCHEME'] ?? 'https') . '://' . ($_SERVER['HTTP_HOST'] ?? 'localhost') . ($_SERVER['REQUEST_URI'] ?? '/');

    $subject = 'Neuro Wellness Dojo — page visit: ' . $page;
    $body = "A visitor landed on {$page}.\n\n"
          . "URL: {$url}\n"
          . "IP: {$ip}\n"
          . "Time: " . date('c') . "\n"
          . "User-Agent: {$ua}\n";

    @nwd_send_mail($config, $config['intake_email'], $subject, $body);
    $_SESSION[$key] = true;
}
