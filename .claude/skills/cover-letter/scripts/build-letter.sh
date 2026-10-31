#!/usr/bin/env bash
#
# Build one cover letter into letters/out/ and remove every auxiliary file.
#
#   bash .claude/skills/cover-letter/scripts/build-letter.sh letters/cover-letter-<slug>.tex [--name <Company>]
#
# Output: letters/out/Cover_Letter-Robert_Sirvio-<Company>.pdf
# <Company> defaults to the slug with each hyphen-separated part capitalised and
# joined with underscores (nordea-bank -> Nordea_Bank). Override with --name.
#
# Exit codes: 0 built, 1 build failed (relevant log lines are printed), 3 bad usage.
set -euo pipefail

usage() { echo "usage: $0 letters/cover-letter-<slug>.tex [--name <Company>]" >&2; exit 3; }

TEX=""
NAME=""
while [ $# -gt 0 ]; do
  case "$1" in
    --name) NAME="${2:-}"; shift 2 ;;
    -h|--help) usage ;;
    *) TEX="$1"; shift ;;
  esac
done
[ -n "$TEX" ] || usage

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
[ -f "$TEX" ] || { echo "error: $TEX does not exist" >&2; exit 3; }
TEX_ABS="$(cd "$(dirname "$TEX")" && pwd)/$(basename "$TEX")"
LETTERS="$REPO/letters"
TEMPLATE="$LETTERS/cover-letter.template.tex"

if [ "$TEX_ABS" = "$TEMPLATE" ]; then
  echo "error: refusing to build the template itself; copy it to letters/cover-letter-<slug>.tex first" >&2
  exit 3
fi
case "$TEX_ABS" in
  "$LETTERS"/cover-letter-*.tex) ;;
  *) echo "error: letter must be letters/cover-letter-<slug>.tex (that pattern is git-ignored)" >&2; exit 3 ;;
esac

BASE="$(basename "$TEX_ABS" .tex)"
SLUG="${BASE#cover-letter-}"
if [ -z "$NAME" ]; then
  NAME="$(echo "$SLUG" | tr '-' '\n' | sed 's/^\(.\)/\U\1/' | paste -sd '_')"
fi
JOB="Cover_Letter-Robert_Sirvio-${NAME}"
OUT="$LETTERS/out"
LOG="$OUT/$JOB.log"
BUILD_OUTPUT="$OUT/$JOB.build.txt"
mkdir -p "$OUT"

cd "$LETTERS"
set +e
latexmk -outdir=out -jobname="$JOB" "$BASE.tex" >"$BUILD_OUTPUT" 2>&1
RC=$?
set -e

if [ $RC -ne 0 ] || [ ! -s "$OUT/$JOB.pdf" ]; then
  echo "BUILD FAILED (latexmk rc=$RC). Relevant log lines:" >&2
  if [ -f "$LOG" ]; then
    grep -nE '^!|^l\.[0-9]+|Undefined control sequence|Missing|Emergency stop|LaTeX Error' "$LOG" | head -40 >&2
  else
    tail -40 "$BUILD_OUTPUT" >&2
  fi
  # Leave no aux files behind even on failure; a stale PDF from an earlier
  # successful build is kept so the user still has something to look at.
  latexmk -c -outdir=out -jobname="$JOB" "$BASE.tex" >/dev/null 2>&1 || true
  unlink "$BUILD_OUTPUT" 2>/dev/null || true
  [ -s "$OUT/$JOB.pdf" ] || unlink "$OUT/$JOB.pdf" 2>/dev/null || true   # lualatex leaves an empty PDF behind
  echo "(aux files removed; for the full log run: cd letters && latexmk -outdir=out -jobname=$JOB $BASE.tex)" >&2
  exit 1
fi

WARN="$(grep -cE 'Overfull \\[hv]box' "$LOG" || true)"
PAGES="$(python3 -I -c 'import sys, pypdf; print(len(pypdf.PdfReader(sys.argv[1]).pages))' "$OUT/$JOB.pdf" 2>/dev/null || echo '?')"

# Drop every regeneratable file; `latexmk -c` keeps only the PDF.
latexmk -c -outdir=out -jobname="$JOB" "$BASE.tex" >/dev/null 2>&1 || true
unlink "$BUILD_OUTPUT" 2>/dev/null || true

echo "built: $OUT/$JOB.pdf"
echo "pages: $PAGES"
[ "$PAGES" = "1" ] || echo "WARNING: a cover letter should fit on one page" >&2
[ "$WARN" = "0" ] || echo "note: $WARN overfull box warning(s); check the PDF visually" >&2
LEFT="$(ls "$OUT" | grep -vE '\.pdf$|^\.gitkeep$' || true)"
[ -z "$LEFT" ] || echo "WARNING: non-PDF files left in letters/out: $LEFT" >&2

# Word runs copied verbatim from the CV (both documents are sent together).
CV_PDF="$REPO/cv/CV.pdf"
CHECK="$SCRIPT_DIR/check-overlap.py"
if [ -f "$CV_PDF" ]; then
  python3 -I "$CHECK" "$OUT/$JOB.pdf" "$CV_PDF" 2>&1 | sed 's/^/CV overlap: /' || true
else
  echo "CV overlap: skipped, cv/CV.pdf not found (build it with: cd cv && latexmk CV.tex)"
fi
