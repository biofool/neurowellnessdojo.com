# Component: deploy-script

**Path:** `sync.sh` (820 lines)
**Revision:** d77a399

## Responsibility

Bash script for deploying the site to peec.biz via rsync over SSH. Also
handles log fetching, report generation, and (legacy) media/cache/review sync.

## Relevant Commands

| Command | Description | Used by this site? |
|---------|-------------|-------------------|
| `deploy` | `git push` + rsync (no prompt) | Yes |
| `upload` | rsync with dry-run + confirm | Yes |
| `dryrun` | Preview only | Yes |
| `download` | Download from server | Yes |
| `logs` | Fetch access logs | Yes |
| `report` | Fetch logs + stats | Yes |
| `help` | Show usage | Yes |
| `cache` | Mirror .cache/ from server | No (legacy) |
| `push-cache` | Push .cache/ to server | No (legacy) |
| `pull-review` | Pull review-data from server | No (legacy) |
| `push-review` | Push review-data to server | No (legacy) |
| `push-uploads` | Push uploads to peer | No (legacy) |
| `pull-uploads` | Pull uploads from peer | No (legacy) |
| `media` | Sync ClipQuotes/Berkeley videos | No (legacy) |
| `hash` | Generate access link hash | No (legacy) |

## Dependencies

| Dependency | Type | Evidence |
|------------|------|----------|
| rsync | Runtime binary | `sync.sh:21,131-136` |
| ssh | Runtime binary | `sync.sh:24` |
| scp | Runtime binary | `sync.sh:287` |
| `~/.ssh/quantumaikido_ed25519` | SSH key file | `sync.sh:8` |
| git | Runtime binary | `sync.sh:754` |
| python3 | Runtime binary (report) | `sync.sh:139-143` |
| `.env` (optional) | Config file | `sync.sh:37-42` |

## Configuration

- `SITE_NAME`: auto-detected from directory basename (line 4)
- `REMOTE_USER`: `peecbiz` (line 6)
- `REMOTE_PATH`: `public_html/${SITE_NAME}/` (line 7)
- `SSH_KEY`: `~/.ssh/quantumaikido_ed25519` (line 8)
- Known remotes: peec.biz (production), 10.3.0.122 (LAN) (lines 11-14)

## Excludes (files not deployed)

Key excludes relevant to this site:
- `.git/`, `tests/`, `*.py`, `*.sh`, `*.md`, `*.pdf`
- `logs/`, `.env`, `.claude/`, `.pytest_cache/`
- `sync.sh` itself (line 96)
- `config.php` is **NOT** excluded — deployed to server

**Evidence:** OBSERVED — `sync.sh:54-115`.

## Change Guidance

- **Adding a new file type to exclude:** add to EXCLUDES array (line 54)
- **Changing remote server:** add to KNOWN_REMOTES array (line 11)
- **This script has ~600 lines of legacy code** from quantumaikido.com that
  is not used by neurowellnessdojo.com (video archive, cache, review, media)
- **Test coverage:** none (shell script, no tests)
