# Component Index

| Component | File(s) | Responsibility |
|-----------|---------|----------------|
| [submit-handler](submit-handler.md) | `submit.php` | Form processing: security, email, Sheets |
| [ab-variant](ab-variant.md) | `includes/variant.php` | A/B test assignment and word swaps |
| [mail](mail.md) | `includes/mail.php` | Email sending and visit notifications |
| [page-renderer](page-renderer.md) | `index.php`, `contact.php`, `includes/head.php`, `includes/footer.php` | Page rendering pipeline |
| [sheets-webhook](sheets-webhook.md) | `apps-script.gs` | Google Sheets intake logging |
| [deploy-script](deploy-script.md) | `sync.sh` | rsync-based deployment |
