#!/usr/bin/env bash
#
# Upload a built cover letter PDF to the cover-letters folder in Google Drive.
#
#   bash .claude/skills/cover-letter/scripts/push-to-drive.sh letters/out/<file>.pdf
#
# Two transports, tried in this order:
#   1. an rclone remote (default remote "gdrive", folder "cover-letters")
#   2. a locally synced Drive folder (Google Drive for Desktop), if DRIVE_SYNC_DIR is set
#
# Optional settings live in ~/.config/cover-letter/drive.conf (shell syntax):
#   RCLONE_REMOTE=gdrive
#   DRIVE_FOLDER=cover-letters
#   DRIVE_SYNC_DIR=/mnt/g/My Drive/cover-letters   # only for transport 2
#
# Exit codes: 0 uploaded, 1 upload failed, 2 no transport configured (setup
# instructions printed; see DRIVE-SETUP.md next to SKILL.md), 3 bad usage.
set -euo pipefail

PDF="${1:-}"
[ -n "$PDF" ] && [ -f "$PDF" ] || { echo "usage: $0 letters/out/<file>.pdf" >&2; exit 3; }
case "$PDF" in *.pdf) ;; *) echo "error: only the built PDF is uploaded, never the .tex" >&2; exit 3 ;; esac
PDF_ABS="$(cd "$(dirname "$PDF")" && pwd)/$(basename "$PDF")"
PDF_NAME="$(basename "$PDF_ABS")"

RCLONE_REMOTE="gdrive"
DRIVE_FOLDER="cover-letters"
DRIVE_SYNC_DIR=""
CONF="$HOME/.config/cover-letter/drive.conf"
# shellcheck disable=SC1090
[ -f "$CONF" ] && . "$CONF"

SETUP_DOC="$(cd "$(dirname "$0")/.." && pwd)/DRIVE-SETUP.md"

# --- 1. rclone -----------------------------------------------------------------
if command -v rclone >/dev/null 2>&1; then
  if rclone listremotes 2>/dev/null | grep -qx "${RCLONE_REMOTE}:"; then
    DEST="${RCLONE_REMOTE}:${DRIVE_FOLDER}"
    if rclone copy "$PDF_ABS" "$DEST/" --no-traverse; then
      echo "uploaded: $PDF_NAME -> Google Drive /$DRIVE_FOLDER (remote $RCLONE_REMOTE)"
      rclone lsl "$DEST/$PDF_NAME" 2>/dev/null || true
      exit 0
    fi
    echo "error: rclone upload to $DEST failed" >&2
    exit 1
  fi
  echo "rclone is installed but has no remote named '${RCLONE_REMOTE}:'." >&2
  echo "Configured remotes: $(rclone listremotes 2>/dev/null | paste -sd ' ' || echo none)" >&2
fi

# --- 2. locally synced Drive folder ----------------------------------------------
if [ -n "$DRIVE_SYNC_DIR" ]; then
  if [ -d "$DRIVE_SYNC_DIR" ]; then
    cp -f "$PDF_ABS" "$DRIVE_SYNC_DIR/"
    echo "copied: $PDF_NAME -> $DRIVE_SYNC_DIR (Google Drive for Desktop syncs it)"
    exit 0
  fi
  echo "error: DRIVE_SYNC_DIR=$DRIVE_SYNC_DIR is not a directory" >&2
  exit 1
fi

cat >&2 <<MSG

NOT UPLOADED: no Google Drive transport is configured on this machine.
The PDF is ready at $PDF_ABS

One-time setup (about two minutes; run it yourself in your own terminal, the
Claude Code hook blocks sudo and interactive commands):
  1. sudo apt install rclone
  2. rclone config        # new remote -> name: gdrive, type: drive, scope: 3 (drive.file)
  3. rerun this upload, or ask Claude to push the letter again
Walkthrough with every prompt answered: $SETUP_DOC
MSG
exit 2
