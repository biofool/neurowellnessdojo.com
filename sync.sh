#!/bin/bash

LOCAL_PATH="$(cd "$(dirname "$0")" && pwd)/"
REMOTE_HOST="peec.biz"
REMOTE_USER="peecbiz"
REMOTE_PATH="public_html/neurowellnessdojo.com/"
[[ "$(hostname)" == "LAPTOP-8FVD6SBV" ]] && REMOTE_HOST="10.3.0.122"
[[ "$REMOTE_HOST" =~ ^10\. ]] && REMOTE_PATH="~/projects/neurowellnessdojo.com/" && REMOTE_USER="kkron"
SSH_KEY="$HOME/.ssh/quantumaikido_ed25519"
SCP_KEY_ARGS=(-i "$SSH_KEY")
LOGS_DIR="${LOCAL_PATH}/logs/"
ACCESS_LOG_PATH="access-logs/neurowellnessdojo.com.peec.biz-ssl_log"
ARCHIVE_LOG_PATH="logs/neurowellnessdojo.com.peec.biz-ssl_log"

if [[ "$(uname -s)" == "Linux" ]]; then
    RSYNC_BIN="rsync"
    RSYNC_KEY="$HOME/.ssh/quantumaikido_ed25519"
    RSYNC_LOCAL="$LOCAL_PATH"
    RSYNC_SSH_CMD="ssh -i $RSYNC_KEY -o IdentitiesOnly=yes -o StrictHostKeyChecking=no"
else
    # cwrsync paths (Cygwin-based, needs /cygdrive/ and its own ssh)
    RSYNC_BIN="/c/ProgramData/chocolatey/lib/rsync/tools/bin/rsync.exe"
    RSYNC_SSH="/cygdrive/c/ProgramData/chocolatey/lib/rsync/tools/bin/ssh.exe"
    RSYNC_KEY="/cygdrive/c/Users/sensie-ok/.ssh/quantumaikido_ed25519"
    RSYNC_KNOWN="/cygdrive/c/Users/sensie-ok/.ssh/known_hosts"
    RSYNC_LOCAL="/cygdrive/c/Users/sensie-ok/projects/neurowellnessdojo.com/"
    RSYNC_SSH_CMD="$RSYNC_SSH -i $RSYNC_KEY -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=$RSYNC_KNOWN"
fi
RSYNC_REMOTE="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"

# Load peer archive config from .env
_env="${LOCAL_PATH}.env"
ARCHIVE_PEER_HOST=$(grep "^ARCHIVE_PEER_HOST=" "$_env" 2>/dev/null | cut -d= -f2-)
ARCHIVE_PEER_USER=$(grep "^ARCHIVE_PEER_USER=" "$_env" 2>/dev/null | cut -d= -f2-)
ARCHIVE_PEER_PATH=$(grep "^ARCHIVE_PEER_PATH=" "$_env" 2>/dev/null | cut -d= -f2-)
VIDEOARCHIVE_JSON=$(grep "^VIDEOARCHIVE=" "$_env" 2>/dev/null | cut -d= -f2-)
unset _env

# Peer uploads paths and SSH command
UPLOADS_LOCAL="${RSYNC_LOCAL}private/uploads/"
UPLOADS_REMOTE="${ARCHIVE_PEER_USER}@${ARCHIVE_PEER_HOST}:${ARCHIVE_PEER_PATH}"
if [[ "$(uname -s)" == "Linux" ]]; then
    PEER_SSH_CMD="ssh -i $RSYNC_KEY -o IdentitiesOnly=yes -o StrictHostKeyChecking=no"
else
    PEER_SSH_CMD="$RSYNC_SSH -i $RSYNC_KEY -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=$RSYNC_KNOWN"
fi

# Always-excluded files — mirrors .gitignore plus additional local artifacts
EXCLUDES=(
    # Protect server-side home directory essentials from --delete
    --exclude='.ssh/'
    --exclude='bin/'
    --exclude='.bashrc'
    --exclude='.bash_profile'
    --exclude='.profile'
    --exclude='.bash_history'
    --exclude='videos/'
    --exclude='projects/'
    --exclude='.git/'
    --exclude='.idea/'
    --exclude='__pycache__/'
    --exclude='.venv/'
    --exclude='.cache/'
    --exclude='private/'
    --exclude='review-queue/'
    --exclude='QuantumAikido/'
    --exclude='tests/'
    --exclude='htmlcov/'
    --exclude='reel/'
    --exclude='shorts/'
    --exclude='youtube/'
    --exclude='logs/'
    --exclude='.env'
    --exclude='.coverage'
    --exclude='.DS_Store'
    --exclude='Thumbs.db'
    --exclude='nul'
    --exclude='process-queue.json'
    --exclude='manage-rejected.log'
    --exclude='*.tmp'
    --exclude='screenlog.*'
    --exclude='~$*'
    --exclude='review-data*.json'
    --exclude='sync-eng.bat'
    --exclude='video-report.ps1'
    --exclude='cache-crc-report.txt'
    --exclude='cache-crc-summary.ps1'
    --exclude='pytest.ini'
    --exclude='.pytest_cache/'
    --exclude='.claude/'
    --exclude='sync.sh'
    --exclude='qa-sync.bat'
    --exclude='cache-sync.bat'
    --exclude='neurowellnessdojo.com/'
    --exclude='mirror/'
    # Non-web files: documents, local tools, and scripts never served from the site
    --exclude='*.pdf'
    --exclude='*.docx'
    --exclude='*.doc'
    --exclude='*.xlsx'
    --exclude='*.xls'
    --exclude='*.py'
    --exclude='*.sh'
    --exclude='*.bat'
    --exclude='*.ps1'
    --exclude='*.md'
    --exclude='Research/'
    --exclude='requirements.txt'
    --exclude='CLAUDE.md'
)

# Server-only dirs (excluded from default uploads, included via scope flags)
SERVER_ONLY=(
    --exclude='.well-known/'
    --exclude='cgi-bin/'
    --exclude='Interviews/'
)

# Large media dirs (excluded unless --video)
VIDEO_EXCLUDES=(
    --exclude='instagram/'
    --exclude='thumbnails/'
)

do_rsync() {
    if [[ "$(uname -s)" == "Linux" ]]; then
        "$RSYNC_BIN" "$@"
    else
        MSYS_NO_PATHCONV=1 "$RSYNC_BIN" "$@"
    fi
}

python_cmd() {
    if [[ "$(uname -s)" == "Linux" ]]; then
        python3 "$@"
    else
        /c/Python312/python.exe "$@"
    fi
}

# Verify both local and remote hosts are listed in VIDEOARCHIVE.hosts before
# any peer-to-peer sync proceeds.  Call as: require_videoarchive "$ARCHIVE_PEER_HOST"
require_videoarchive() {
    local remote_host="${1:-}"
    if [[ -z "$VIDEOARCHIVE_JSON" ]]; then
        echo "Error: VIDEOARCHIVE not set in .env — this command requires a video archive host."
        exit 1
    fi
    local local_host enabled in_local
    local_host=$(hostname)
    enabled=$(python_cmd -c "import json,sys; d=json.loads(sys.argv[1]); print(str(d.get('enabled',False)).lower())" "$VIDEOARCHIVE_JSON" 2>/dev/null)
    if [[ "$enabled" != "true" ]]; then
        echo "Error: VIDEOARCHIVE.enabled is not true in .env"
        exit 1
    fi
    in_local=$(python_cmd -c "import json,sys; d=json.loads(sys.argv[1]); print(str(sys.argv[2] in d.get('hosts',[])).lower())" "$VIDEOARCHIVE_JSON" "$local_host" 2>/dev/null)
    if [[ "$in_local" != "true" ]]; then
        echo "Error: this host ($local_host) is not in VIDEOARCHIVE.hosts"
        exit 1
    fi
    if [[ -n "$remote_host" ]]; then
        local in_remote
        in_remote=$(python_cmd -c "import json,sys; d=json.loads(sys.argv[1]); print(str(sys.argv[2] in d.get('hosts',[])).lower())" "$VIDEOARCHIVE_JSON" "$remote_host" 2>/dev/null)
        if [[ "$in_remote" != "true" ]]; then
            echo "Error: peer host ($remote_host) is not in VIDEOARCHIVE.hosts"
            exit 1
        fi
    fi
}

# Pre-parse arguments: extract command, scope, and flags regardless of order
CMD=""
SCOPE=""
HAS_VIDEO=0
YES=0
REMOTE_PATH_FLAG=""
_next_p=0
for arg in "$@"; do
    if [[ $_next_p -eq 1 ]]; then REMOTE_PATH_FLAG="$arg"; _next_p=0; continue; fi
    case "$arg" in
        -p) _next_p=1 ;;
        --video) HAS_VIDEO=1 ;;
        -y|--yes) YES=1 ;;
        upload|download|dryrun|cache|push-cache|pull-review|push-review|push-uploads|pull-uploads|logs|report|hash|deploy|media|help)
            [ -z "$CMD" ] && CMD="$arg"
            ;;
        once)
            SCOPE="$arg"
            ;;
        *)
            # Treat as scope if we have a command but no scope yet
            [ -n "$CMD" ] && [ -z "$SCOPE" ] && SCOPE="$arg"
            ;;
    esac
done
unset _next_p
[[ -n "$REMOTE_PATH_FLAG" ]] && REMOTE_PATH="$REMOTE_PATH_FLAG"
RSYNC_REMOTE="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"

build_excludes() {
    local scope="$1"
    local -a excl=("${EXCLUDES[@]}")

    case "$scope" in
        interviews)
            # Include Interviews/, exclude other server-only
            excl+=(--exclude='.well-known/' --exclude='cgi-bin/' --exclude='QuantumAikido/')
            ;;
        neurowellness)
            # Include QuantumAikido/, exclude other server-only
            excl+=(--exclude='.well-known/' --exclude='cgi-bin/' --exclude='Interviews/')
            ;;
        all)
            # Include everything server-side (only protect .well-known and cgi-bin)
            excl+=(--exclude='.well-known/' --exclude='cgi-bin/')
            ;;
        *)
            # Default: exclude all server-only dirs
            excl+=("${SERVER_ONLY[@]}")
            ;;
    esac

    [ $HAS_VIDEO -eq 0 ] && excl+=("${VIDEO_EXCLUDES[@]}")

    echo "${excl[@]}"
}

merge_review_files() {
    # For each local review-data*.json, merge its entries into the server copy.
    # Server entries win for any key present in both (true append-only behaviour).
    local tmp_server tmp_merged basename
    shopt -s nullglob
    for local_file in "${LOCAL_PATH}"review-data*.json; do
        basename="${local_file##*/}"
        tmp_server=$(mktemp /tmp/server-review-XXXXXX.json)
        tmp_merged=$(mktemp /tmp/merged-review-XXXXXX.json)

        if scp "${SCP_KEY_ARGS[@]}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}${basename}" "$tmp_server" 2>/dev/null; then
            # Merge: newer reviewedAt timestamp wins per video; acceptedOrder union (server order preserved, local additions appended)
            if python_cmd -c "
import json, sys
a = json.load(open(sys.argv[1]))  # local
b = json.load(open(sys.argv[2]))  # server
merged = dict(b)
# Merge videos: pick the entry with the more recent reviewedAt
merged_videos = dict(a.get('videos', {}))
for k, v in b.get('videos', {}).items():
    a_ts = merged_videos[k].get('reviewedAt', '') if k in merged_videos else ''
    b_ts = v.get('reviewedAt', '')
    if b_ts >= a_ts:
        merged_videos[k] = v
merged['videos'] = merged_videos
# Merge acceptedOrder: preserve server order, append local-only entries
server_order = b.get('acceptedOrder', [])
local_order = a.get('acceptedOrder', [])
server_set = set(server_order)
extra = [p for p in local_order if p not in server_set]
merged['acceptedOrder'] = server_order + extra
print(json.dumps(merged, indent=2))
" "$local_file" "$tmp_server" > "$tmp_merged" 2>/dev/null; then
                scp "${SCP_KEY_ARGS[@]}" "$tmp_merged" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}${basename}" \
                    && echo "  $basename  merged ✓" || echo "  $basename  merge upload FAILED"
            else
                echo "  $basename  merge error (jq failed), skipping"
            fi
        else
            # Server doesn't have this file yet — just push local copy
            scp "${SCP_KEY_ARGS[@]}" "$local_file" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}${basename}" \
                && echo "  $basename  pushed (new) ✓" || echo "  $basename  push FAILED"
        fi

        rm -f "$tmp_server" "$tmp_merged"
    done
    shopt -u nullglob
}

fetch_logs() {
    echo "Fetching latest log files..."
    mkdir -p "$LOGS_DIR"

    # Logs always live on peec.biz regardless of which machine we're on
    local LOG_HOST="peec.biz"
    local LOG_USER="peecbiz"

    # Download current access log (overwrites - it's the live log)
    scp "${SCP_KEY_ARGS[@]}" "${LOG_USER}@${LOG_HOST}:~/${ACCESS_LOG_PATH}" "${LOGS_DIR}current-ssl.log" 2>/dev/null

    # Download archived logs for current month (only if newer)
    MONTH=$(date +"%b-%Y")
	  for MONTH in $(date +"%b-%Y") $(date -d "1 month ago" +"%b-%Y"); do
		  scp "${SCP_KEY_ARGS[@]}" "${LOG_USER}@${LOG_HOST}:~/logs/neurowellnessdojo.com.peec.biz-ssl_log-${MONTH}.gz" "${LOGS_DIR}archive-ssl-${MONTH}.gz" 2>/dev/null
		  if [ -f "${LOGS_DIR}archive-ssl-${MONTH}.gz" ]; then
			  gunzip -f "${LOGS_DIR}archive-ssl-${MONTH}.gz" 2>/dev/null
		  fi
	  done

    # Combine logs
    cat "${LOGS_DIR}archive-ssl-"* "${LOGS_DIR}current-ssl.log" 2>/dev/null | sort -u > "${LOGS_DIR}combined.log"

    echo "Logs updated: ${LOGS_DIR}combined.log"
}

generate_report() {
    LOG_FILE="${LOGS_DIR}combined.log"

    if [ ! -f "$LOG_FILE" ]; then
        echo "No log file found. Run '$0 logs' first."
        exit 1
    fi

    UPLOAD=$(grep -c 'upload\.php' "$LOG_FILE")
    FILTERED_LOG=$(grep -v 'upload\.php' "$LOG_FILE")
    TOTAL=$(echo "$FILTERED_LOG" | wc -l)
    UNIQUE=$(echo "$FILTERED_LOG" | awk '{print $1}' | sort -u | wc -l)
    BOT=$(echo "$FILTERED_LOG" | grep -iE '(bot|spider|crawler|slurp|bing|google|yandex|baidu|semrush|ahrefs|mj12|dotbot|bytespider)' | wc -l)
    HUMAN=$((TOTAL - BOT))
    REVIEW=$(echo "$FILTERED_LOG" | grep -c 'review\.php')

    echo ""
    echo "========================================"
    echo "  NEUROWELLNESSDOJO.COM VISITOR STATISTICS"
    echo "  Generated: $(date)"
    echo "========================================"
    echo ""
    echo "SUMMARY"
    echo "  Total Requests:  $TOTAL"
    echo "  Unique Visitors: $UNIQUE"
    echo "  Bot Traffic:     $BOT"
    echo "  Human Traffic:   $HUMAN"
    echo "  Review Activity: $REVIEW"
    echo "  Upload Activity: $UPLOAD"
    echo ""
    echo "TOP 15 PAGES"
    echo "----------------------------------------"
    echo "$FILTERED_LOG" | awk '{print $7}' | grep -vE '\.(css|js|png|jpg|jpeg|gif|ico|woff|woff2|svg|webp)$' | sort | uniq -c | sort -rn | head -15
    echo ""
    echo "REQUESTS BY DAY"
    echo "----------------------------------------"
    echo "$FILTERED_LOG" | awk '{print $4}' | cut -d: -f1 | tr -d '[' | sort -t/ -k3,3n -k2,2M -k1,1n | uniq -c | tail -14
    echo ""
    echo "TOP REFERRERS"
    echo "----------------------------------------"
    echo "$FILTERED_LOG" | awk -F'"' '{print $4}' | grep -v '^-$' | grep -vi 'neurowellness' | sort | uniq -c | sort -rn | head -10
    echo ""
    echo "HTTP STATUS CODES"
    echo "----------------------------------------"
    echo "$FILTERED_LOG" | awk '{print $9}' | sort | uniq -c | sort -rn
    echo ""

    # Upload report
    UPLOAD_LOG="${LOCAL_PATH}private/uploads/upload_log.json"
    if [ -f "$UPLOAD_LOG" ]; then
        echo "RECENT UPLOADS"
        echo "----------------------------------------"
        # Show last 10 uploads with timestamp, filename, and size
        python_cmd -c "
import json, sys
d = json.load(open(sys.argv[1]))
for e in d[-10:]:
    mb = int(float(e.get('file_size',0)) / 1048576)
    print(f\"  {e.get('timestamp','')} | {e.get('file_name','')} ({mb}MB)\")
" "$UPLOAD_LOG" 2>/dev/null || echo "  (error reading upload log)"
        UPLOAD_COUNT=$(python_cmd -c "import json,sys; print(len(json.load(open(sys.argv[1]))))" "$UPLOAD_LOG" 2>/dev/null || echo "0")
        UPLOAD_SIZE=$(python_cmd -c "import json,sys; d=json.load(open(sys.argv[1])); print(sum(int(float(e.get('file_size',0))) for e in d))" "$UPLOAD_LOG" 2>/dev/null || echo "0")
        UPLOAD_SIZE_MB=$(echo "scale=1; $UPLOAD_SIZE / 1048576" | bc 2>/dev/null || echo "?")
        echo ""
        echo "  Total uploads: $UPLOAD_COUNT files ($UPLOAD_SIZE_MB MB)"
        echo ""
    fi
}

case "$CMD" in
    upload)
        EXCL=$(build_excludes "$SCOPE")
        echo ""
        echo "========================================"
        echo "  DRY RUN - Preview of upload changes"
        [ -n "$SCOPE" ] && echo "  Scope: $SCOPE"
        [ $HAS_VIDEO -eq 1 ] && echo "  Video: included"
        echo "========================================"
        echo ""
        do_rsync -avz --dry-run --delete --chmod=F644,D755 $EXCL -e "$RSYNC_SSH_CMD" "$RSYNC_LOCAL" "$RSYNC_REMOTE"
        echo ""
        echo "========================================"
        echo "  NOTE: For substantial updates, upload to the for-review link first."
        echo "========================================"
        if [[ $YES -eq 1 ]]; then CONFIRM=y; else read -p "Proceed with upload? (y/N): " CONFIRM; fi
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            echo ""
            echo "Uploading..."
            do_rsync -avz --delete --chmod=F644,D755 $EXCL -e "$RSYNC_SSH_CMD" "$RSYNC_LOCAL" "$RSYNC_REMOTE"
            echo ""
            echo "Merging review-data files..."
            merge_review_files
            echo ""
            echo "Upload complete."
        else
            echo "Upload cancelled."
        fi
        ;;
    download)
        echo ""
        echo "========================================"
        echo "  DRY RUN - Preview of download changes"
        echo "========================================"
        echo ""
        do_rsync -avz --dry-run --exclude='.git/' -e "$RSYNC_SSH_CMD" "$RSYNC_REMOTE" "$RSYNC_LOCAL"
        echo ""
        echo "========================================"
        if [[ $YES -eq 1 ]]; then CONFIRM=y; else read -p "Proceed with download? (y/N): " CONFIRM; fi
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            echo ""
            echo "Downloading..."
            do_rsync -avz --exclude='.git/' -e "$RSYNC_SSH_CMD" "$RSYNC_REMOTE" "$RSYNC_LOCAL"
            echo ""
            echo "Download complete."
        else
            echo "Download cancelled."
        fi
        ;;
    dryrun)
        EXCL=$(build_excludes "$SCOPE")
        echo ""
        echo "========================================"
        echo "  DRY RUN - Preview only (no changes)"
        [ -n "$SCOPE" ] && echo "  Scope: $SCOPE"
        [ $HAS_VIDEO -eq 1 ] && echo "  Video: included"
        echo "========================================"
        echo ""
        if [ "$SCOPE" == "download" ]; then
            do_rsync -avz --dry-run --exclude='.git/' -e "$RSYNC_SSH_CMD" "$RSYNC_REMOTE" "$RSYNC_LOCAL"
        else
            do_rsync -avz --dry-run --delete $EXCL -e "$RSYNC_SSH_CMD" "$RSYNC_LOCAL" "$RSYNC_REMOTE"
        fi
        ;;
    cache)
        # Cache download: mirror server .cache/ to local .cache/
        CACHE_REMOTE="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}.cache/"
        CACHE_LOCAL="${RSYNC_LOCAL}.cache/"
        CACHE_EXCLUDES=(--exclude='clips/shorts/' --exclude='clips/youtube/' --exclude='clips/debug/' --exclude='videos/')
        INTERVAL=300
        ITERATIONS=36
        COUNT=0

        mkdir -p "${LOCAL_PATH}.cache"

        echo "========================================"
        echo "  Cache Sync - Video Download Monitor"
        echo "  Server: ${REMOTE_HOST}:${REMOTE_PATH}.cache/"
        echo "  Local:  .cache/"
        echo "========================================"

        if [ "$SCOPE" == "once" ]; then
            echo ""
            echo "[$(date)] Single sync starting..."
            do_rsync -avz "${CACHE_EXCLUDES[@]}" -e "$RSYNC_SSH_CMD" "$CACHE_REMOTE" "$CACHE_LOCAL"
            echo "[$(date)] Sync complete."
        else
            echo "  Checking every 5 minutes for 3 hours"
            echo "========================================"
            echo ""
            while [ $COUNT -lt $ITERATIONS ]; do
                COUNT=$((COUNT + 1))
                echo "[$(date)] Sync ${COUNT}/${ITERATIONS}..."
                do_rsync -avz "${CACHE_EXCLUDES[@]}" -e "$RSYNC_SSH_CMD" "$CACHE_REMOTE" "$CACHE_LOCAL"
                echo "[$(date)] Sync ${COUNT} complete."
                echo ""
                if [ $COUNT -ge $ITERATIONS ]; then
                    echo "All ${ITERATIONS} sync cycles complete."
                    break
                fi
                echo "Waiting 5 minutes until next sync..."
                sleep $INTERVAL
            done
        fi
        ;;
    push-cache)
        PUSH_SOURCE="${SCOPE:-${LOCAL_PATH}.cache}"
        if [[ ! -d "$PUSH_SOURCE" ]]; then
            echo "Error: source directory not found: $PUSH_SOURCE"
            echo "Usage: $0 push-cache [/path/to/.cache]"
            exit 1
        fi
        PUSH_SOURCE="${PUSH_SOURCE%/}/"
        PUSH_DEST="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}.cache/"
        PUSH_EXCLUDES=(
            --exclude='clips/debug/'
            --exclude='clips/shorts/'
            --exclude='clips/youtube/'
            --exclude='videos/'
        )

        echo ""
        echo "========================================"
        echo "  DRY RUN - Push .cache/ to server"
        echo "  Source: $PUSH_SOURCE"
        echo "  Dest:   ${REMOTE_HOST}:${REMOTE_PATH}.cache/"
        echo "========================================"
        echo ""
        do_rsync -avz --dry-run "${PUSH_EXCLUDES[@]}" -e "$RSYNC_SSH_CMD" "$PUSH_SOURCE" "$PUSH_DEST"
        echo ""
        echo "========================================"
        if [[ $YES -eq 1 ]]; then CONFIRM=y; else read -p "Proceed with push? (y/N): " CONFIRM; fi
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            echo ""
            echo "Pushing..."
            do_rsync -avz "${PUSH_EXCLUDES[@]}" -e "$RSYNC_SSH_CMD" "$PUSH_SOURCE" "$PUSH_DEST"
            echo ""
            echo "Push complete."
        else
            echo "Push cancelled."
        fi
        ;;
    pull-review)
        PULL_DEST="${SCOPE:-$(cd "$LOCAL_PATH/../ClipQuotes" 2>/dev/null && pwd)}"
        if [[ -z "$PULL_DEST" || ! -d "$PULL_DEST" ]]; then
            echo "Error: destination directory not found: ${PULL_DEST:-../ClipQuotes}"
            echo "Usage: $0 pull-review [/path/to/destination]"
            exit 1
        fi

        echo ""
        echo "========================================"
        echo "  Pull Review Data from Server"
        echo "  From: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
        echo "  To:   $PULL_DEST"
        echo "========================================"
        echo ""

        scp "${SCP_KEY_ARGS[@]}" \
            "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}review-data*.json" \
            "$PULL_DEST/" 2>/dev/null && echo "  review-data*.json  ✓" || echo "  review-data*.json  (none found)"

        scp "${SCP_KEY_ARGS[@]}" \
            "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}rejected-videos.txt" \
            "$PULL_DEST/" 2>/dev/null && echo "  rejected-videos.txt ✓" || echo "  rejected-videos.txt (not found)"

        echo ""
        echo "Review data synced to: $PULL_DEST"
        ;;
    push-review)
        PUSH_SRC="${SCOPE:-$(cd "$LOCAL_PATH/../ClipQuotes" 2>/dev/null && pwd)}"
        if [[ -z "$PUSH_SRC" || ! -d "$PUSH_SRC" ]]; then
            echo "Error: source directory not found: ${PUSH_SRC:-../ClipQuotes}"
            echo "Usage: $0 push-review [/path/to/source]"
            exit 1
        fi

        echo ""
        echo "========================================"
        echo "  Push Review Data to Server"
        echo "  From: $PUSH_SRC"
        echo "  To:   ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
        echo "========================================"
        echo ""

        if [[ -f "$PUSH_SRC/review-data.json" ]]; then
            scp "${SCP_KEY_ARGS[@]}" \
                "$PUSH_SRC/review-data.json" \
                "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}review-data.json" \
                && echo "  review-data.json      ✓" || echo "  review-data.json      FAILED"
        else
            echo "  review-data.json      (not found, skipping)"
        fi

        if [[ -f "$PUSH_SRC/deleted-rejections.json" ]]; then
            scp "${SCP_KEY_ARGS[@]}" \
                "$PUSH_SRC/deleted-rejections.json" \
                "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}deleted-rejections.json" \
                && echo "  deleted-rejections.json ✓" || echo "  deleted-rejections.json FAILED"
        fi

        echo ""
        echo "Review data pushed to server."
        ;;
    push-uploads)
        require_videoarchive "$ARCHIVE_PEER_HOST"
        echo ""
        echo "========================================"
        echo "  DRY RUN - Push uploads/ to peer"
        echo "  From: ${LOCAL_PATH}private/uploads/"
        echo "  To:   ${UPLOADS_REMOTE}"
        echo "========================================"
        echo ""
        do_rsync -avz --dry-run -e "$PEER_SSH_CMD" "$UPLOADS_LOCAL" "$UPLOADS_REMOTE"
        echo ""
        echo "========================================"
        if [[ $YES -eq 1 ]]; then CONFIRM=y; else read -p "Proceed with push? (y/N): " CONFIRM; fi
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            echo ""
            echo "Pushing uploads to $ARCHIVE_PEER_HOST..."
            do_rsync -avz -e "$PEER_SSH_CMD" "$UPLOADS_LOCAL" "$UPLOADS_REMOTE"
            echo ""
            echo "Push complete."
        else
            echo "Push cancelled."
        fi
        ;;
    pull-uploads)
        require_videoarchive "$ARCHIVE_PEER_HOST"
        echo ""
        echo "========================================"
        echo "  DRY RUN - Pull uploads/ from peer"
        echo "  From: ${UPLOADS_REMOTE}"
        echo "  To:   ${LOCAL_PATH}private/uploads/"
        echo "========================================"
        echo ""
        do_rsync -avz --dry-run -e "$PEER_SSH_CMD" "$UPLOADS_REMOTE" "$UPLOADS_LOCAL"
        echo ""
        echo "========================================"
        if [[ $YES -eq 1 ]]; then CONFIRM=y; else read -p "Proceed with pull? (y/N): " CONFIRM; fi
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            echo ""
            echo "Pulling uploads from $ARCHIVE_PEER_HOST..."
            do_rsync -avz -e "$PEER_SSH_CMD" "$UPLOADS_REMOTE" "$UPLOADS_LOCAL"
            echo ""
            echo "Pull complete."
        else
            echo "Pull cancelled."
        fi
        ;;
    media)
        # Sync ClipQuotes and Berkeley video folders directly to peec.biz:/public_html/
        # These are large media dirs managed outside of git — never go through neurowellness.com/
        MEDIA_USER="peecbiz"
        MEDIA_HOST="peec.biz"
        MEDIA_BASE="public_html/"
        # Derive the parent of the repo in the correct rsync path format
        MEDIA_RSYNC_BASE="${RSYNC_LOCAL%neurowellnessdojo.com/}"

        # ClipQuotes: default to sibling dir ../ClipQuotes, override via .env CLIPQUOTES_LOCAL
        _menv="${LOCAL_PATH}.env"
        CLIPQUOTES_LOCAL_OVERRIDE=$(grep "^CLIPQUOTES_LOCAL=" "$_menv" 2>/dev/null | cut -d= -f2-)
        BERKELEY_LOCAL_OVERRIDE=$(grep "^BERKELEY_LOCAL=" "$_menv" 2>/dev/null | cut -d= -f2-)
        unset _menv

        if [[ -n "$CLIPQUOTES_LOCAL_OVERRIDE" ]]; then
            CLIPQUOTES_RSYNC="$CLIPQUOTES_LOCAL_OVERRIDE"
        else
            CLIPQUOTES_RSYNC="${MEDIA_RSYNC_BASE}ClipQuotes/"
        fi
        CLIPQUOTES_DEST="${MEDIA_USER}@${MEDIA_HOST}:${MEDIA_BASE}ClipQuotes/"

        if [[ -n "$BERKELEY_LOCAL_OVERRIDE" ]]; then
            BERKELEY_RSYNC="$BERKELEY_LOCAL_OVERRIDE"
        else
            BERKELEY_RSYNC="${MEDIA_RSYNC_BASE}BerkeleyVideos/"
        fi
        BERKELEY_DEST="${MEDIA_USER}@${MEDIA_HOST}:${MEDIA_BASE}BerkeleyVideos/"

        echo ""
        echo "========================================"
        echo "  DRY RUN - Media sync to peec.biz"
        echo "  ClipQuotes: $CLIPQUOTES_RSYNC"
        echo "           → ${MEDIA_HOST}:${MEDIA_BASE}ClipQuotes/"
        echo "  Berkeley:  $BERKELEY_RSYNC"
        echo "           → ${MEDIA_HOST}:${MEDIA_BASE}BerkeleyVideos/"
        echo "========================================"
        echo ""
        echo "--- ClipQuotes ---"
        do_rsync -avz --dry-run -e "$RSYNC_SSH_CMD" "$CLIPQUOTES_RSYNC" "$CLIPQUOTES_DEST" 2>&1 | tail -20
        echo ""
        echo "--- Berkeley Videos ---"
        do_rsync -avz --dry-run -e "$RSYNC_SSH_CMD" "$BERKELEY_RSYNC" "$BERKELEY_DEST" 2>&1 | tail -20
        echo ""
        echo "========================================"
        if [[ $YES -eq 1 ]]; then CONFIRM=y; else read -p "Proceed with media sync? (y/N): " CONFIRM; fi
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            echo ""
            echo "Syncing ClipQuotes..."
            do_rsync -avz -e "$RSYNC_SSH_CMD" "$CLIPQUOTES_RSYNC" "$CLIPQUOTES_DEST"
            echo ""
            echo "Syncing Berkeley Videos..."
            do_rsync -avz -e "$RSYNC_SSH_CMD" "$BERKELEY_RSYNC" "$BERKELEY_DEST"
            echo ""
            echo "Media sync complete."
        else
            echo "Media sync cancelled."
        fi
        ;;
    hash)
        _env="${LOCAL_PATH}.env"
        SECRET_PREFIX=$(grep "^SECRET_PREFIX=" "$_env" 2>/dev/null | cut -d= -f2-)
        SECRET_PREFIX="${SECRET_PREFIX:-quantum-aikido-videos-}"
        HASH_LENGTH=$(grep "^HASH_LENGTH=" "$_env" 2>/dev/null | cut -d= -f2-)
        HASH_LENGTH="${HASH_LENGTH:-12}"
        unset _env
        DATE_ARG="${SCOPE:-$(date +%Y-%m-%d)}"
        HASH=$(echo -n "${SECRET_PREFIX}${DATE_ARG}" | sha256sum | cut -c1-${HASH_LENGTH})
        echo ""
        echo "Date:  $DATE_ARG"
        echo "Hash:  $HASH"
        echo "Link:  ?d=${DATE_ARG}&key=${HASH}"
        echo ""
        ;;
    deploy)
        EXCL=$(build_excludes "$SCOPE")
        echo ""
        echo "========================================"
        echo "  DEPLOY — git push + rsync to peec.biz"
        [ -n "$SCOPE" ] && echo "  Scope: $SCOPE"
        [ $HAS_VIDEO -eq 1 ] && echo "  Video: included"
        echo "========================================"
        echo ""
        git -C "$(dirname "$0")" push
        echo ""
        echo "Uploading to peec.biz..."
        do_rsync -avz --delete --chmod=F644,D755 $EXCL -e "$RSYNC_SSH_CMD" "$RSYNC_LOCAL" "$RSYNC_REMOTE"
        echo ""
        echo "Merging review-data files..."
        merge_review_files
        echo ""
        echo "Deploy complete."
        ;;
    logs)
        fetch_logs
        ;;
    report|"")
        fetch_logs
        generate_report
        ;;
    help)
        echo "Usage: $0 [command] [--video]"
        echo ""
        echo "Commands:"
        echo "  deploy [scope]     - git push + rsync directly to peec.biz (no prompt)"
        echo "  upload [scope]     - Upload to server (dry-run preview, then confirm)"
        echo "  download           - Download from server (dry-run preview, then confirm)"
        echo "  dryrun [scope]     - Show what upload would do (no prompt)"
        echo "  dryrun download    - Show what download would do (no prompt)"
        echo "  media              - Sync ClipQuotes + Berkeley videos to peec.biz:/public_html/"
        echo "  cache [once]       - Mirror server .cache/ to local (once or 5-min loop)"
        echo "  push-cache [path]  - Push local .cache/ to server (dry-run + confirm)"
        echo "  pull-review [path] - Pull review-data*.json + rejected-videos.txt from server"
        echo "  push-review [path] - Push review-data.json + deleted-rejections.json to server"
        echo "  push-uploads       - Push private/uploads/ to archive peer (videoarchive hosts only)"
        echo "  pull-uploads       - Pull uploads/ from archive peer (videoarchive hosts only)"
        echo "  hash [YYYY-MM-DD]  - Generate access link hash for a date (default: today)"
        echo "  logs               - Fetch latest server access logs only"
        echo "  report             - Fetch logs and generate statistics report"
        echo "  help               - Show this help message"
        echo ""
        echo "Upload scopes (for deploy/upload/dryrun):"
        echo "  (none)             - Site files only — git-tracked HTML/CSS/JS/PHP (default)"
        echo "  interviews         - Also sync Interviews/ dir"
        echo "  neurowellness            - Also sync neurowellness/ dir"
        echo "  all                - Sync everything (interviews + neurowellness)"
        echo ""
        echo "File management:"
        echo "  Only web-facing files (HTML/CSS/JS/PHP/images) are uploaded by default."
        echo "  PDFs, *.py, *.sh, *.bat, *.md, Research/ etc. are always excluded."
        echo "  Media dirs (ClipQuotes, BerkeleyVideos) sync via 'media' command only."
        echo "  Override media paths via CLIPQUOTES_LOCAL / BERKELEY_LOCAL in .env"
        echo ""
        echo "Options:"
        echo "  --video     - Include instagram/ and thumbnails/ folders (excluded by default)"
        echo "  -p PATH     - Override remote path (e.g. -p ~/public_html/)"
        ;;
    *)
        echo "Unknown command: $CMD"
        echo "Run '$0 help' for usage."
        exit 1
        ;;
esac
