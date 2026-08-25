# Component: sheets-webhook

**Path:** `apps-script.gs` (33 lines) — deployed to Google Apps Script
**Revision:** d77a399

## Responsibility

Receives POST requests from `submit.php` and appends intake submissions as
rows in a Google Sheet. Provides a structured record alongside email.

## Interfaces

- **Input:** HTTP POST with JSON body:
  `name`, `email`, `message`, `variant`, `referral`, `timestamp`
- **Output:** JSON `{ok: true}` on success, `{ok: false, error: ...}` on failure

## Sheet Schema

| Column | Field | Source |
|--------|-------|--------|
| A | timestamp | `data.timestamp` or `new Date().toISOString()` |
| B | name | `data.name` |
| C | email | `data.email` |
| D | message | `data.message` |
| E | variant | `data.variant` |

**Note:** `referral` field is sent by `submit.php` (line 83) but **not
appended** to the Sheet by `apps-script.gs`. This is a discrepancy.

**Evidence:** OBSERVED — `apps-script.gs:17-23` (appendRow without referral),
`submit.php:83` (payload includes referral).

## Dependencies

| Dependency | Type | Evidence |
|------------|------|----------|
| Google Sheets | External service | `apps-script.gs:15` |
| `SpreadsheetApp` | Apps Script API | `apps-script.gs:15` |

## Consumers

| Consumer | How |
|----------|-----|
| `submit.php` | HTTP POST via `file_get_contents()` with 5s timeout |

## Deployment

1. Create Google Sheet with header row: `timestamp | name | email | message | variant`
2. Extensions → Apps Script → paste file contents
3. Deploy → New deployment → Web app
   - Execute as: Me
   - Who has access: Anyone
4. Copy URL → paste into `config.php` as `sheets_webhook_url`

**Evidence:** DECLARED — `apps-script.gs:1-11` (comment instructions),
`README.md:46-56`.

## Failure Paths

| Failure | Behavior |
|---------|----------|
| JSON parse error | Returns `{ok: false, error: err.toString()}` |
| Sheet access error | Caught, returns `{ok: false, error: ...}` |
| Network timeout (caller side) | `submit.php` 5s timeout, `@` suppressed |

## Change Guidance

- **Adding referral column:** add `data.referral` to `appendRow` array in
  `apps-script.gs:17-23`, add header to Sheet
- **Changing fields:** update both `apps-script.gs` and `submit.php` payload
- **Test coverage:** no automated tests (external service)
