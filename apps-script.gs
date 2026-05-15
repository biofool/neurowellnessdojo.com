// Neuro Wellness Dojo — intake-to-sheet webhook
//
// HOW TO USE
// 1. Create a Google Sheet. Add a header row: timestamp | name | email | message | variant
// 2. Extensions → Apps Script.
// 3. Replace the default code with this file's contents.
// 4. Deploy → New deployment → type "Web app".
//    - Execute as: Me
//    - Who has access: Anyone (this only allows POST; it doesn't expose the Sheet)
// 5. Copy the Web app URL. Paste it into config.php as 'sheets_webhook_url'.

function doPost(e) {
    try {
        const data = JSON.parse(e.postData.contents);
        const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();

        sheet.appendRow([
            data.timestamp || new Date().toISOString(),
            data.name      || '',
            data.email     || '',
            data.message   || '',
            data.variant   || ''
        ]);

        return ContentService
            .createTextOutput(JSON.stringify({ ok: true }))
            .setMimeType(ContentService.MimeType.JSON);
    } catch (err) {
        return ContentService
            .createTextOutput(JSON.stringify({ ok: false, error: err.toString() }))
            .setMimeType(ContentService.MimeType.JSON);
    }
}
