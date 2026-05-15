<?php
declare(strict_types=1);

$current_page = 'contact';
$config = require __DIR__ . '/config.php';
require __DIR__ . '/includes/mail.php';
nwd_notify_visit($config, 'contact');

if (!empty($config['maintenance'])) {
    http_response_code(503);
    echo "Site temporarily unavailable.";
    exit;
}

require __DIR__ . '/includes/variant.php';

$variant = nwd_variant($config);
$t = nwd_terms($variant);

$page_title = 'Contact — Neuro Wellness Dojo';
include __DIR__ . '/includes/head.php';
?>

<div class="container">
<article>

  <header class="hero">
    <h1>Contact</h1>
    <p class="lede">Request your free session or reach out with a question.</p>
  </header>

  <section id="intake" class="intake">
    <h2>Request your free session</h2>
    <p>Three things, all that's needed.</p>

    <form action="/submit.php" method="post" novalidate>
      <input type="hidden" name="csrf" value="<?= htmlspecialchars($_SESSION['csrf'], ENT_QUOTES, 'UTF-8') ?>">
      <input type="hidden" name="variant" value="<?= htmlspecialchars($variant, ENT_QUOTES, 'UTF-8') ?>">

      <!-- Honeypot. Real visitors leave this empty; bots tend to fill it. -->
      <div class="hp" aria-hidden="true">
        <label>Website <input type="text" name="website" tabindex="-1" autocomplete="off"></label>
      </div>

      <div class="field">
        <label for="name">Name</label>
        <input id="name" type="text" name="name" required maxlength="120" autocomplete="name">
      </div>

      <div class="field">
        <label for="email">Email</label>
        <input id="email" type="email" name="email" required maxlength="200" autocomplete="email">
      </div>

      <div class="field">
        <label for="message">What's bringing you here?</label>
        <textarea id="message" name="message" rows="4" maxlength="2000"></textarea>
      </div>

      <p class="reassurance">Dr. Clemans will never see what you wrote.</p>

      <button type="submit" class="button">Send</button>
    </form>
  </section>

  <section>
    <h2>Other ways to reach us</h2>
    <p>Email: <a href="mailto:<?= htmlspecialchars($config['intake_email'], ENT_QUOTES, 'UTF-8') ?>"><?= htmlspecialchars($config['intake_email'], ENT_QUOTES, 'UTF-8') ?></a></p>
    <p>We respond within one business day.</p>
  </section>

</article>
</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
