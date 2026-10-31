# CV #

LaTeX sources for my CV and cover letters, built on a vendored (and locally patched) moderncv v1.2.0.

### Layout ###

* *cv/* — `CV.tex` and its pictures; build output stays in this folder.
* *letters/* — `CoverLetter_template.tex`. Real letters are copies named `cover-letter-<company>.tex`, which are git-ignored.
* *moderncv/* — the vendored moderncv class, styles and colour schemes. Locally patched (look for `Roope-edit`); do not replace with the TeX Live version.
* *CV_localization.sty* — localized content and address macros shared by the CV and the letters.
* *Revisions/* — archived PDFs.

### Building ###

Each document folder has a `latexmkrc` that selects lualatex and puts `../moderncv` and the repo root ahead of the system TeX tree (which ships a different, incompatible moderncv):

```bash
cd cv && latexmk CV.tex
cd letters && latexmk cover-letter-<company>.tex
```

Without latexmk, run from inside the folder: ```TEXINPUTS=../moderncv:..: lualatex CV.tex```

### Scripts ###

* *change_locale.sh*
	* Change the localization for both content and section of the given .tex file
	* Example: ```bash change_locale.sh -fi cv/CV.tex```
