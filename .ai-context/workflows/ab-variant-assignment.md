# Workflow: A/B Variant Assignment

**Revision:** d77a399

## Entry Point

Call to `nwd_variant(array $config): string` in `includes/variant.php`,
invoked by `index.php:31`, `contact.php:17`, `KC-dds-ref/index.php:22`.

## Execution Path

1. **Read cookie name** — `variant.php:7`
   - `$name = $config['variant_cookie'];` → `'nwd_variant'`

2. **Check existing cookie** — `variant.php:9-11`
   - If `$_COOKIE[$name]` exists and is 'A' or 'B' → return it (sticky)

3. **Assign new variant** — `variant.php:13`
   - `$assigned = (mt_rand(0, 1) === 0) ? 'A' : 'B';`
   - 50/50 coin flip using Mersenne Twister (not cryptographically secure)

4. **Set cookie** — `variant.php:15-25`
   - Name: `nwd_variant`
   - Value: 'A' or 'B'
   - Expires: now + `variant_cookie_ttl` (1 year)
   - Path: `/`
   - Secure: based on `$_SERVER['HTTPS']`
   - HttpOnly: true
   - SameSite: Lax

5. **Return assigned variant** — `variant.php:27`

6. **Get word swaps** — caller invokes `nwd_terms($variant)` (variant.php:31-48)
   - Returns array with keys: `modality`, `modality_short`, `discipline`,
     `lineage_phrase`, `opening_para`
   - Variant A: "somatic" language
   - Variant B: "mind/body" language

## Evidence

| Step | File:Lines | Test |
|------|-----------|------|
| Cookie read | `variant.php:9-11` | (no direct test) |
| Random assignment | `variant.php:13` | (no direct test) |
| Cookie set | `variant.php:15-25` | (no direct test) |
| Word swaps | `variant.php:31-48` | (indirectly via page render tests) |

## Failure Paths

| Failure | Behavior |
|---------|----------|
| Cookie not set (headers already sent) | PHP warning, variant still returned but not sticky |
| Config missing `variant_cookie` | PHP undefined index warning |
| Config missing `variant_cookie_ttl` | PHP undefined index warning |

## Change Guidance

- **Stop the test:** hardcode `return 'A';` or `return 'B';` in `nwd_variant()`
- **Add variant C:** update `mt_rand(0, 2)`, `in_array` check, add terms array,
  update `submit.php:41` `in_array` check
- **Change TTL:** edit `config.php` `variant_cookie_ttl`
- **Note:** `mt_rand()` is not cryptographically secure — acceptable for A/B
  testing but not for security-sensitive random
