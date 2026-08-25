# Workflow: Deploy

**Revision:** d77a399

## Entry Point

```bash
./sync.sh deploy --remote peec.biz
```

## Execution Path

1. **Detect site name** — `sync.sh:3-4`
   - `LOCAL_PATH` = script directory
   - `SITE_NAME` = directory basename (`neurowellnessdojo.com`)

2. **Resolve remote** — `sync.sh:220-247`
   - `--remote peec.biz` → match in `KNOWN_REMOTES` array
   - Sets `REMOTE_HOST=peec.biz`, `REMOTE_USER=peecbiz`, `REMOTE_PATH=public_html/neurowellnessdojo.com/`

3. **Build excludes** — `sync.sh:249-275`
   - Default scope: EXCLUDES + SERVER_ONLY + VIDEO_EXCLUDES
   - Excludes: `.git/`, `tests/`, `*.py`, `*.sh`, `*.md`, `*.pdf`, `logs/`, `.env`, etc.
   - `config.php` is NOT excluded (needed at runtime)

4. **Git push** — `sync.sh:754`
   - `git -C "$(dirname "$0")" push`

5. **Rsync upload** — `sync.sh:757`
   - `rsync -avz --delete --chmod=F644,D755 $EXCL -e "ssh -i $SSH_KEY ..." "$LOCAL" "$REMOTE"`
   - `--delete` removes files on server not present locally
   - `--chmod=F644,D755` sets file/directory permissions

6. **Merge review files** — `sync.sh:759-760`
   - `merge_review_files()` — legacy function, no review-data files for this site

7. **Complete** — `sync.sh:762`

## Evidence

| Step | File:Lines |
|------|-----------|
| Site name detection | `sync.sh:3-4` |
| Remote resolution | `sync.sh:220-247` |
| Excludes | `sync.sh:54-115, 249-275` |
| Git push | `sync.sh:754` |
| Rsync | `sync.sh:757` |
| Deploy case | `sync.sh:745-763` |

## Failure Paths

| Failure | Behavior |
|---------|----------|
| SSH key missing | rsync/ssh fails with error |
| Remote host unreachable | rsync fails with error |
| Git push fails | Script continues to rsync (no error check) |
| rsync fails | Script continues to merge_review_files (no error check) |

**Note:** The `deploy` command has **no error checking** between git push and
rsync, or between rsync and merge. A git push failure does not abort the deploy.

## Change Guidance

- **Safe deploy:** use `upload` instead of `deploy` — it does a dry-run
  preview and asks for confirmation
- **Preview changes:** `./sync.sh dryrun --remote peec.biz`
- **Download from server:** `./sync.sh download --remote peec.biz`
- **This script is shared infrastructure** — changes affect deployment
  reliability. The script has ~600 lines of legacy code not used by this site.
