# Testing Index

## Test Framework

- **Framework:** pytest 9.1.1
- **Language:** Python 3.14
- **Type:** Integration tests (HTTP requests against PHP built-in server)
- **Location:** `tests/test_pages.py` (200 lines, 19 tests)
- **Config:** `pytest.ini` (`testpaths = tests`)

## Test Coverage

| Area | Tests | Count |
|------|-------|-------|
| Page rendering | `test_home_200`, `test_contact_200`, `test_privacy_200`, `test_thankyou_200`, `test_404_page_returns_404` | 5 |
| Code gate | `test_home_shows_code_gate_when_locked`, `test_home_unlocks_with_correct_code`, `test_home_shows_error_on_wrong_code` | 3 |
| Contact form | `test_contact_has_intake_form` | 1 |
| KC-dds-ref page | `test_kc_dds_ref_200`, `test_kc_dds_ref_content`, `test_kc_dds_ref_is_noindex`, `test_kc_dds_ref_no_dental_anxiety_language`, `test_kc_dds_ref_has_intake_form`, `test_kc_dds_ref_referral_field` | 6 |
| submit.php security | `test_submit_rejects_get`, `test_submit_rejects_missing_csrf`, `test_submit_rejects_wrong_csrf`, `test_honeypot_gives_silent_redirect` | 4 |
| **Total** | | **19** |

## What's NOT Tested

- Rate limiting (no test for 429 response)
- Field validation errors (no test for 400 with invalid name/email/message)
- Email sending (sendmail not available in test env)
- Google Sheets webhook (external service)
- `.htaccess` rules (not enforced by `php -S`)
- A/B variant assignment logic (no direct test)
- Maintenance mode (config has maintenance=false)
- `sync.sh` deployment (no shell tests)

## Test Execution

```bash
pytest tests/           # run all tests
pytest tests/ -v        # verbose output
pytest tests/ -k submit # run only submit-related tests
```

Tests auto-start a PHP server on `localhost:8765` via session-scoped fixture.
