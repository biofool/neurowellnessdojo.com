<?php
declare(strict_types=1);

$config = require __DIR__ . '/../config.php';
require __DIR__ . '/../includes/mail.php';

if (!empty($config['maintenance'])) {
    http_response_code(503);
    echo "Site temporarily unavailable.";
    exit;
}

require __DIR__ . '/../includes/variant.php';

$page_title   = 'Neuro Wellness Dojo — Dr. Clemans Referral';
$meta_robots  = 'noindex,nofollow';
$current_page = '';

include __DIR__ . '/../includes/head.php';

nwd_notify_visit($config, 'kc-dds-ref');
$variant = nwd_variant($config);
$t = nwd_terms($variant);
?>

<div class="container">
<article>

  <header class="hero">
    <h1>Neuro Wellness Dojo</h1>
    <p class="lede">Relaxation and nervous system skills — referred by Dr. Clemans.</p>
    <p>Dr. Clemans referred you here. The first twenty-minute session is free, by WhatsApp or Zoom. No preparation needed.</p>
    <p class="cta"><a class="button" href="#intake">Claim your free session <span class="parenthetical">(free)</span></a></p>
  </header>

  <section>
    <h2>What this is</h2>
    <?php if ($variant === 'A'): ?>
      <p>A somatic practice &mdash; the skill of noticing what your nervous system is actually doing and learning to shift it. Breath, posture, where tension lives in your body. Small adjustments with a long lineage behind them.</p>
    <?php else: ?>
      <p>A mind/body practice &mdash; working with the link between your thoughts and your physical state. When you learn to settle one, the other tends to follow. The techniques are simple and portable. You don&rsquo;t need to believe in anything for them to work.</p>
    <?php endif; ?>
    <p>These are skills you can use anywhere &mdash; at rest, at work, or in any situation that tends to put you on edge. They don&rsquo;t require quiet music, a special posture, or thinking positively.</p>
  </section>

  <section>
    <h2>What a first session is like</h2>
    <p>Twenty minutes. We meet on video. You say a little about what&rsquo;s been going on. Together we try one or two practices right then, in the call &mdash; not explained in theory, actually tried.</p>
    <p>If something lands, we can keep going. If nothing does, you&rsquo;ve lost twenty minutes and nothing else. No follow-up sales pitch. If you want a second session, we&rsquo;ll talk about what that looks like &mdash; including cost &mdash; in our first session, not before.</p>
  </section>

  <section>
    <h2>Your coach</h2>
    <p>Kenneth Kron has practiced aikido and <?= htmlspecialchars($t['discipline'], ENT_QUOTES, 'UTF-8') ?> for forty years, working directly with Robert Nadeau and Richard Moon. This is coaching, not therapy.</p>
  </section>

  <section>
    <h2>The practice</h2>
    <p>Neuro Wellness Dojo is built on a combined lineage of one hundred years of aikido and <?= htmlspecialchars($t['lineage_phrase'], ENT_QUOTES, 'UTF-8') ?>, drawn from several of the tradition&rsquo;s foundational teachers.</p>
  </section>

  <section id="intake" class="intake">
    <h2>Request your free session</h2>
    <p>Three things, all that&rsquo;s needed.</p>

    <form action="/submit.php" method="post" novalidate>
      <input type="hidden" name="csrf" value="<?= htmlspecialchars($_SESSION['csrf'], ENT_QUOTES, 'UTF-8') ?>">
      <input type="hidden" name="variant" value="<?= htmlspecialchars($variant, ENT_QUOTES, 'UTF-8') ?>">
      <input type="hidden" name="referral" value="KC-dds-ref">

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
        <label for="message">What would you like to work on? <span style="font-style:italic;opacity:0.7">(optional)</span></label>
        <textarea id="message" name="message" rows="4" maxlength="2000"></textarea>
      </div>

      <p class="reassurance">Dr. Clemans will never see what you wrote.</p>

      <button type="submit" class="button">Send</button>
    </form>
  </section>

  <section class="faq">
    <h2>Questions you might have</h2>

    <h3>Is this therapy?</h3>
    <p>No. This is coaching &mdash; practical skills you can use. If you&rsquo;re looking for therapy, please see a licensed therapist.</p>

    <h3>Will Dr. Clemans see what I wrote?</h3>
    <p>No. What you write here goes to your coach only. Not shared with Dr. Clemans, her office, or anyone else.</p>

    <h3>What if I don&rsquo;t like it?</h3>
    <p>The first session is twenty minutes and free. If it isn&rsquo;t for you, that&rsquo;s the end of it. No pressure, no follow-up pitch.</p>

    <h3>What about my data?</h3>
    <p>We don&rsquo;t share it, sell it, or use AI tools that retain it. Our <a href="/privacy.php">Privacy Policy</a> spells this out.</p>

    <h3>Can I do this on my phone?</h3>
    <p>Yes &mdash; WhatsApp or Zoom, whichever is easier.</p>
  </section>

</article>
</div>

<?php include __DIR__ . '/../includes/footer.php'; ?>
