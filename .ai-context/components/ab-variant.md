# Component: ab-variant

**Path:** `includes/variant.php` (48 lines)
**Revision:** d77a399

## Responsibility

Server-side A/B testing. Assigns visitors to variant 'A' (somatic language)
or 'B' (mind/body language) via a sticky cookie. Provides variant-specific
word swaps for page rendering.

## Interfaces

- `nwd_variant(array $config): string` — returns 'A' or 'B'
- `nwd_terms(string $variant): array` — returns associative array of word swaps

## Word Swap Keys

| Key | Variant A | Variant B |
|-----|-----------|-----------|
| `modality` | somatic practice | mind/body practice |
| `modality_short` | somatic | mind/body |
| `discipline` | somatic disciplines | mind/body disciplines |
| `lineage_phrase` | somatic work | mind/body work |
| `opening_para` | "A somatic practice..." | "A mind/body practice..." |

**Evidence:** OBSERVED — `variant.php:31-48`.

## Dependencies

| Dependency | Type | Evidence |
|------------|------|----------|
| `$config['variant_cookie']` | Config | `variant.php:7` |
| `$config['variant_cookie_ttl']` | Config | `variant.php:19` |
| `$_COOKIE` | Runtime state | `variant.php:9` |
| `mt_rand()` | Runtime (PHP built-in) | `variant.php:13` |
| `setcookie()` | Runtime (PHP built-in) | `variant.php:15` |

## Consumers

| Consumer | Usage |
|----------|-------|
| `index.php` | `nwd_variant()`, `nwd_terms()` — both locked and unlocked views |
| `contact.php` | `nwd_variant()`, `nwd_terms()` |
| `KC-dds-ref/index.php` | `nwd_variant()`, `nwd_terms()` + inline variant conditional |
| `submit.php` | `require` only (variant received via POST, not called) |

## Cookie Configuration

- Name: `nwd_variant` (from config)
- TTL: 1 year (`60 * 60 * 24 * 365` = 31536000 seconds)
- Path: `/`
- Secure: based on `$_SERVER['HTTPS']`
- HttpOnly: true
- SameSite: Lax

**Evidence:** OBSERVED — `variant.php:15-25`.

## Change Guidance

- **Stopping the test:** hardcode return value in `nwd_variant()` or set
  cookie manually (per README.md line 75)
- **Adding a variant:** modify `mt_rand` range, add terms array, update
  `in_array` check in `nwd_variant` and `submit.php:41`
- **Changing word swaps:** edit the arrays in `nwd_terms()` — affects all
  pages that use `$t['...']`
- **Test coverage:** no direct unit tests; tested indirectly via page render tests
