<?php
declare(strict_types=1);

// Returns 'A' (somatic) or 'B' (mind/body). Sticky per visitor via cookie.
function nwd_variant(array $config): string
{
    $name = $config['variant_cookie'];

    if (isset($_COOKIE[$name]) && in_array($_COOKIE[$name], ['A', 'B'], true)) {
        return $_COOKIE[$name];
    }

    $assigned = (mt_rand(0, 1) === 0) ? 'A' : 'B';

    setcookie(
        $name,
        $assigned,
        [
            'expires'  => time() + $config['variant_cookie_ttl'],
            'path'     => '/',
            'secure'   => !empty($_SERVER['HTTPS']),
            'httponly' => true,
            'samesite' => 'Lax',
        ]
    );

    return $assigned;
}

// Words that swap between variants. Lookup by key.
function nwd_terms(string $variant): array
{
    return $variant === 'A'
        ? [
            'modality'        => 'somatic practice',
            'modality_short'  => 'somatic',
            'discipline'      => 'somatic disciplines',
            'lineage_phrase'  => 'somatic work',
            'opening_para'    => "A somatic practice. That's a longer word for paying attention to what's actually happening in your body — your breath, your shoulders, the place where your jaw is holding on — and learning small ways to ease it.",
        ]
        : [
            'modality'        => 'mind/body practice',
            'modality_short'  => 'mind/body',
            'discipline'      => 'mind/body disciplines',
            'lineage_phrase'  => 'mind/body work',
            'opening_para'    => "A mind/body practice. That's the simple idea that your thoughts and your body are connected — that what your jaw is doing affects what your mind is doing, and the other way around — and that you can learn small ways to settle both.",
        ];
}
