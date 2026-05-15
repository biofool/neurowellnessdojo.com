<?php
http_response_code(404);
$page_title = 'Page Not Found';
include __DIR__ . '/includes/head.php';
?>

<div class="container">
<article>
  <header class="hero">
    <h1>Page not found</h1>
    <p class="lede">The page you're looking for isn't here.</p>
    <p>You might have followed an old link or mistyped the address.</p>
    <p class="cta"><a class="button" href="/">Return home</a></p>
  </header>
</article>
</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
