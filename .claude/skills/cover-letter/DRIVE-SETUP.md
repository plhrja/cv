# Google Drive upload: one-time setup

State of this machine when the skill was written (2026-10-31): no Google Drive
tooling at all. No `rclone`, no `gdrive` CLI, no Google Drive for Desktop on the
Windows side (only OneDrive), and no Google Drive MCP connector in Claude Code.
Until one of the transports below exists, `scripts/push-to-drive.sh` exits with
code 2 and prints these steps. Both options are one-off and have to be run by
you: the local Claude Code hook blocks `sudo`, network downloads and interactive
commands, so Claude cannot do them.

## Option A (recommended): rclone

rclone ships its own Google OAuth client, so no Google Cloud project is needed.

1. Install it:

   ```bash
   sudo apt install rclone
   ```

   (Ubuntu's package is fine for this. The newest build is the install script
   on rclone.org/install if you prefer.)

2. Create the remote. Prompts and answers:

   ```text
   rclone config
   e/n/d/r/c/s/q>              n          # new remote
   name>                       gdrive     # the script's default name
   Storage>                    drive      # Google Drive
   client_id>                             # empty
   client_secret>                         # empty
   scope>                      3          # drive.file: rclone sees only files it created itself
   service_account_file>                  # empty
   Edit advanced config?       n
   Use web browser to automatically authenticate?  y
   ```

   rclone opens (or prints) a Google sign-in URL. On WSL2, if no browser pops
   up, paste the URL into a Windows browser; the `http://127.0.0.1:53682/`
   callback reaches WSL through localhost forwarding. Then:

   ```text
   Configure this as a Shared Drive (Team Drive)?  n
   y/e/d>                      y          # keep the remote
   e/n/d/r/c/s/q>              q
   ```

3. Verify: `rclone about gdrive:` prints your quota. With scope 3,
   `rclone lsd gdrive:` stays empty until the first upload. That is expected.

4. Folder: the script uploads to `gdrive:cover-letters/` and creates the folder
   on the first run. With scope 3 rclone cannot see a `cover-letters` folder you
   made by hand in the Drive UI and would create a second one with the same
   name, so either let the script create it or choose scope `1` (full access)
   in step 2.

After that, `bash .claude/skills/cover-letter/scripts/push-to-drive.sh letters/out/<file>.pdf`
uploads, and so does asking Claude to push the letter.

Sharing link, only when you need one: `rclone link gdrive:cover-letters/<file>.pdf`
makes the file readable by anyone holding the link.

## Option B: Google Drive for Desktop on Windows

Install Google Drive for Desktop, create `My Drive/cover-letters`, and make the
drive reachable from WSL (`sudo mount -t drvfs G: /mnt/g`, or switch Drive to
mirroring into your Windows profile). Then tell the script where the folder is:

```bash
mkdir -p ~/.config/cover-letter
echo 'DRIVE_SYNC_DIR="/mnt/g/My Drive/cover-letters"' >> ~/.config/cover-letter/drive.conf
```

The script copies the PDF there and Drive syncs it. rclone is tried first when
both are configured.

## Settings file

`~/.config/cover-letter/drive.conf`, plain shell assignments, every line optional:

```bash
RCLONE_REMOTE=gdrive
DRIVE_FOLDER=cover-letters
DRIVE_SYNC_DIR=
```

## Claude Code Google Drive connector

If a Google Drive or Google Workspace connector is enabled in claude.ai, tools
named `mcp__claude_ai_Google_Drive__*` appear in the session. The Drive
connector has been read-only (search and fetch); check with ToolSearch whether
an upload tool exists before relying on it. rclone stays the dependable path.
