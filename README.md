# CV #

LaTeX sources for my CV and cover letters, built on a vendored (and locally patched) moderncv v1.2.0.

### Layout ###

* *cv/* — `CV.tex` and its pictures; build output stays in this folder.
* *letters/* — `cover-letter.template.tex`. Real letters are copies named `cover-letter-<company>.tex` and their PDFs are built into `letters/out/`; both are git-ignored.
* *moderncv/* — the vendored moderncv class, styles and colour schemes. Locally patched (look for `Roope-edit`); do not replace with the TeX Live version.
* *CV_localization.sty* — localized content and address macros shared by the CV and the letters.
* *Revisions/* — archived PDFs.
* *job-postings/* — job postings the cover-letter skill reads (git-ignored).
* *.claude/skills/cover-letter/* — Claude Code skill that drafts, builds and uploads cover letters (see below).

### Building ###

Each document folder has a `latexmkrc` that selects lualatex and puts `../moderncv` and the repo root ahead of the system TeX tree (which ships a different, incompatible moderncv):

```bash
cd cv && latexmk CV.tex
cd letters && latexmk -outdir=out cover-letter-<company>.tex
```

Without latexmk, run from inside the folder: ```TEXINPUTS=../moderncv:..: lualatex CV.tex```

### Cover letters with Claude Code ###

Save the posting (PDF, Markdown or text) in `job-postings/` and ask Claude Code, e.g. *"write me a cover letter for the Acme posting"*. The `cover-letter` skill then

1. reads the posting and the latest `cv/CV.pdf`,
2. matches the style of the letters already in `letters/out/` (or asks, when there are none),
3. drafts `letters/cover-letter-<company>.tex` from a fresh copy of the template,
4. builds `letters/out/Cover_Letter-Robert_Sirvio-<Company>.pdf` and removes all auxiliary files,
5. checks that no CV sentence was copied verbatim, and
6. on request pushes the PDF to the `cover-letters` folder in Google Drive.

Letters, postings and PDFs stay out of git. The Drive upload needs a one-time `rclone` setup, described in `.claude/skills/cover-letter/DRIVE-SETUP.md`.

### Scripts ###

* *change_locale.sh*
	* Change the localization for both content and section of the given .tex file
	* Example: ```bash change_locale.sh -fi cv/CV.tex```
