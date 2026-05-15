<?php
declare(strict_types=1);

$current_page = 'home';
$config = require __DIR__ . '/config.php';
require __DIR__ . '/includes/mail.php';
nwd_notify_visit($config, 'home');

if (!empty($config['maintenance'])) {
    http_response_code(503);
    echo "Site temporarily unavailable.";
    exit;
}

require __DIR__ . '/includes/variant.php';

$variant = nwd_variant($config);
$t = nwd_terms($variant);

$page_title = 'Neuro Wellness Dojo';
include __DIR__ . '/includes/head.php';
?>

<div class="container">
<article>

  <header class="hero">
    <h1>Neuro Wellness Dojo</h1>
    <p class="lede">A free first session for Dr. Clemans's patients.</p>
    <p>Dr. Clemans referred you, so you know what this is about. The first twenty-minute session is free. We meet by WhatsApp or Zoom. No preparation needed.</p>
    <p class="cta"><a class="button" href="#intake">Deepen your relaxation here <span class="parenthetical">(free)</span></a></p>
  </header>

  <section>
    <h2>What this is</h2>
    <p><?= htmlspecialchars($t['opening_para'], ENT_QUOTES, 'UTF-8') ?></p>
    <p>The skills are simple. They work whether or not you "believe in" them. They don't require quiet music, a special posture, or thinking positively. You can use them sitting in a dental chair.</p>
  </section>

  <section>
    <h2>What a first session is like</h2>
    <p>Twenty minutes. We meet on video. You describe what's going on for you with the dentist. Together you try one or two practices right then, in the call.</p>
    <p>If it helps, we walk through the dental setting in your mind &mdash; the chair, the sounds, the moment when the door opens &mdash; so the practices are tied to where you'll actually use them.</p>
    <p>If anything lands, we can keep going. If nothing does, you've lost nothing. No follow-up sales pitch. If you want a second session, we'll talk about what that looks like &mdash; including cost &mdash; in our first session, not before.</p>
  </section>

  <section>
    <h2>Your coach</h2>
    <p>Kenneth Kron has practiced aikido and <?= htmlspecialchars($t['discipline'], ENT_QUOTES, 'UTF-8') ?> for forty years, working directly with Robert Nadeau and Richard Moon. This is coaching, not therapy.</p>
  </section>

  <section>
    <h2>The practice</h2>
    <p>Neuro Wellness Dojo is built on a combined lineage of one hundred years of aikido and <?= htmlspecialchars($t['lineage_phrase'], ENT_QUOTES, 'UTF-8') ?>, drawn from several of the tradition's foundational teachers.</p>
  </section>

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

  <section class="faq">
    <h2>Questions you might have</h2>

    <h3>Is this therapy?</h3>
    <p>No. This is coaching &mdash; practical skills you can use. If you're looking for therapy, please see a licensed therapist.</p>

    <h3>Will Dr. Clemans see what I wrote?</h3>
    <p>No. What you write here goes to your coach only. Not shared with Dr. Clemans, her office, or anyone else.</p>

    <h3>What if I don't like it?</h3>
    <p>The first session is twenty minutes and free. If it isn't for you, that's the end of it.</p>

    <h3>What about my data?</h3>
    <p>We don't share it, sell it, or use AI tools that retain it. Our <a href="/privacy.php">Privacy Policy</a> spells this out.</p>

    <h3>Can I do this on my phone?</h3>
    <p>Yes &mdash; WhatsApp or Zoom, whichever is easier.</p>
  </section>

</article>
</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
