#!/usr/bin/env python3
"""Report word runs that a cover letter PDF shares verbatim with the CV PDF.

    python3 -I .claude/skills/cover-letter/scripts/check-overlap.py <letter.pdf> <cv.pdf> [--min-words N]

Prints each shared run of at least N consecutive words (default 7). Runs that
are mostly digits or contain an e-mail address are dropped, because the contact
footer is identical in both documents by design. Exit code 0 when nothing is
shared, 1 when at least one run is reported, 2 on usage or read errors.
"""
import re
import sys

try:
    import pypdf
except ImportError:
    print("pypdf is not installed (python3 -m pip install pypdf)", file=sys.stderr)
    sys.exit(2)


def words(path):
    try:
        reader = pypdf.PdfReader(path)
    except Exception as exc:  # noqa: BLE001
        print(f"cannot read {path}: {exc}", file=sys.stderr)
        sys.exit(2)
    text = " ".join((page.extract_text() or "") for page in reader.pages)
    text = text.lower().replace("-\n", "").replace("\n", " ")
    text = re.sub(r"[^\w@+.]+", " ", text)
    return [w.strip(".") for w in text.split() if w.strip(".")]


def footer_like(run):
    noisy = sum(1 for w in run if "@" in w or sum(c.isdigit() for c in w) >= 3)
    return noisy / max(len(run), 1) >= 0.3


def main(argv):
    args = [a for a in argv if not a.startswith("--")]
    n = 7
    if "--min-words" in argv:
        value = argv[argv.index("--min-words") + 1]
        n = int(value)
        args = [a for a in args if a != value]
    if len(args) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    letter, cv = words(args[0]), words(args[1])
    cv_grams = {tuple(cv[i:i + n]) for i in range(len(cv) - n + 1)}

    runs, i = [], 0
    while i <= len(letter) - n:
        if tuple(letter[i:i + n]) in cv_grams:
            j = i + n
            while j < len(letter) and tuple(letter[j - n + 1:j + 1]) in cv_grams:
                j += 1
            run = letter[i:j]
            if not footer_like(run):
                runs.append(run)
            i = j
        else:
            i += 1

    if not runs:
        print(f"OK: no run of {n}+ words is shared with the CV")
        return 0
    print(f"{len(runs)} run(s) of {n}+ words appear verbatim in the CV; rephrase them:")
    for run in runs:
        print(f"  - ({len(run)} words) {' '.join(run)}")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
