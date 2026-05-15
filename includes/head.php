<?php
// Expects $page_title to be set before include. Falls back to brand.
$page_title = $page_title ?? 'Neuro Wellness Dojo';
$current_page = $current_page ?? '';

// CSRF token lives in the session, regenerated per session.
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
if (empty($_SESSION['csrf'])) {
    $_SESSION['csrf'] = bin2hex(random_bytes(32));
}
?><!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="index,follow">
<title><?= htmlspecialchars($page_title, ENT_QUOTES, 'UTF-8') ?></title>
<link rel="stylesheet" href="/assets/css/styles.css">
</head>
<body>
<a href="#main-content" class="skip-link">Skip to main content</a>
<header role="banner">
    <div class="container">
        <div class="header-content">
            <a href="/" class="logo" aria-label="Neuro Wellness Dojo Home">Neuro Wellness Dojo</a>
            <nav aria-label="Main navigation">
                <ul class="nav-links">
                    <li><a href="/"<?= $current_page === 'home' ? ' aria-current="page"' : '' ?>>Home</a></li>
                    <li><a href="/contact.php"<?= $current_page === 'contact' ? ' aria-current="page"' : '' ?>>Contact</a></li>
                    <li><a href="/privacy.php"<?= $current_page === 'privacy' ? ' aria-current="page"' : '' ?>>Privacy</a></li>
                </ul>
            </nav>
        </div>
    </div>
</header>
<main id="main-content" role="main">
