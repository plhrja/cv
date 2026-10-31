---
name: cover-letter
description: "Write, iterate, build and upload a tailored cover letter for a job posting saved in job-postings/, using the moderncv letter template in letters/ and facts from the CV. Use when the user asks for a cover letter, application letter or motivation letter for a specific posting, company or role; asks to revise, shorten or rebuild an existing letter; or asks to push a letter PDF to Google Drive."
---

# Cover letter

Produces `letters/out/Cover_Letter-Robert_Sirvio-<Company>.pdf` from a fresh copy of
`letters/cover-letter.template.tex`, tailored to one posting in `job-postings/` and
argued from the CV. Nothing letter-specific ever reaches version control.

## Ground rules

- **Never edit `letters/cover-letter.template.tex`.** Work in
  `letters/cover-letter-<slug>.tex` (slug = company name, lowercase ascii, hyphens:
  `cover-letter-nordea-bank.tex`). First request for a posting: fresh copy of the
  template. Follow-up edits: the same file.
- **Every claim about Robert comes from the CV.** No invented achievements, numbers,
  tools or dates. If the posting asks for something the CV does not cover, tell the
  user instead of papering over it.
- **Paraphrase.** Both documents are usually sent together. After drafting, re-read the
  fit paragraph next to the CV and rewrite any sentence that keeps a CV line's structure,
  not only its words. The build also reports word runs copied verbatim.
- **Not version-controlled:** the letter `.tex`, everything in `letters/out/`, and
  `job-postings/`. Never `git add` them and never edit `.gitignore` to admit them.
- Run the scripts from the repo root; paths below are relative to it.

## Workflow

### 1. Find and read the posting

`ls job-postings/`, then match the company or role words from the request. Read the
whole file (the Read tool handles PDFs; for `.html` ignore the markup). Zero or several
matches: ask which one with AskUserQuestion, do not guess. If the user gives a URL
instead of a file, fetch it with the web-fetch agent and save the text into
`job-postings/` so later iterations use the same wording.

Note: company, role, team or product, location, the posting's language, must-have and
nice-to-have requirements, responsibilities, what the company says about its mission and
way of working, deadline, named contact and postal address, and where the posting was
published if it says.

### 2. Read the CV

Source of truth is `cv/CV.pdf`. If it is missing or older than `cv/CV.tex`, rebuild it
with `cd cv && latexmk CV.tex` (its aux files are git-ignored). Fall back to the newest
PDF in `Revisions/English/` only if that build fails. Read it with the Read tool and list
employers, roles, dates, responsibilities, technologies, certifications, education and
languages. Map each posting requirement to CV evidence and keep the 2–4 strongest matches.

### 3. Calibrate the style

`ls -t letters/out/*.pdf`, leaving out the letter being built.

- **Earlier letters exist:** Read the newest one or two and record language, register,
  voice, number and length of paragraphs, total length, whether a bold subject line is
  used, opening and closing phrases, how the enclosure is named, and how concrete the
  examples are. Match all of it.
- **None exist:** ask the user in one AskUserQuestion call: register (formal or
  conversational-professional), length (half page, three quarters, full page), language
  (posting's language or English), subject line (yes or no), closing phrase. Skip anything
  the request already settled.

### 4. Collect the one-off facts

Ask once, bundled with step 3's questions when both apply:

- Where the posting was found, if neither the request nor the posting says.
- Recipient, when the posting names nobody: address it to the hiring manager or team and
  use the company name plus the city from the posting. Never invent a street address;
  drop the line rather than guess.
- Anything the posting wants covered in the letter that the CV cannot answer (salary
  request, start date, work permit).

### 5. Write the letter

```bash
cp letters/cover-letter.template.tex letters/cover-letter-<slug>.tex
```

Edit the copy, nothing else:

- `\recipient{<Company>}{<name or title>\\<street>\\<postcode city>}`, lines split with `\\`.
- `\date{<D Month YYYY>}` fixed to today. Never leave `\today`; a rebuild would move it.
- `\opening{...}` and `\closing{...}` in the letter's language.
- Finnish or Swedish letter: set `\def \langname {finnish}` or `{swedish}` so the footer
  address localises, and translate the enclosure line, e.g.
  `\enclosure[Liite]{Ansioluettelo}` or `\enclosure[Bilaga]{Meritförteckning}`.
- Subject line: uncomment and fill the `{\bfseries ...}` line only when step 3 says so.
- Replace the three bracketed placeholders with the body below.

Body structure, always in this order:

1. **Opening, one or two sentences.** Excited to apply for the role at the company, and
   where the posting was found. Nothing else.
2. **Fit.** Why Robert is a very good candidate: the 2–4 strongest requirement-to-evidence
   matches from step 2, phrased as what he did and what came of it, in fresh words. Lead
   with what the posting values most. Two paragraphs are fine for a senior or long posting.
3. **Motivation.** Why this role and this company: what in the posting (domain, product,
   team, technical challenge, way of working, mission) connects to the direction the CV
   shows. Specific to this posting, no generic praise.
4. **Closing.** Availability to talk, pointer to the attached CV, thanks. Two or three
   sentences.

Language: the posting's language unless the user says otherwise. Length: one page,
calibrated in step 3, otherwise 250–350 words. Avoid filler openings ("I am writing
to…"), clichés, restated CV bullets, superlatives without evidence, and more than one
exclamation mark.

LaTeX: escape `& % $ # _ { }` in prose, write `--` for an en dash and `---` for an em
dash, UTF-8 letters such as ä ö å are fine. Add no packages; the preamble stays identical
to the template so the letter keeps the CV's look.

### 6. Build

```bash
bash .claude/skills/cover-letter/scripts/build-letter.sh letters/cover-letter-<slug>.tex [--name <Company>]
```

Writes `letters/out/Cover_Letter-Robert_Sirvio-<Company>.pdf`, deletes every auxiliary
file, prints the page count, warns about a second page or overfull boxes, and ends with
a `CV overlap:` line listing any run of seven or more words shared verbatim with
`cv/CV.pdf` (the identical contact footer is filtered out). Rephrase every listed run
and rebuild. Fix build errors in the `.tex`; never hand-edit anything in `letters/out/`.
Then Read the PDF and check: one page, no stranded single line, address block, date,
enclosure line, footer, no leftover brackets.

### 7. Hand over and iterate

Report the PDF path, the language, the CV facts the fit paragraph rests on, and any
posting requirement the CV does not evidence. Offer the Drive push. Iterate by editing
the same `.tex` and repeating step 6.

Before finishing, `git status --porcelain` must not list the letter, the PDF or the
posting. If it does, something in `.gitignore` changed: stop and tell the user, do not
stage or commit.

### 8. Push to Google Drive

On request, or once the user approves the letter:

```bash
bash .claude/skills/cover-letter/scripts/push-to-drive.sh letters/out/<file>.pdf
```

Uploads the PDF to the `cover-letters` folder of Robert's Drive through rclone (remote
`gdrive`), or copies it into a locally synced Drive folder when one is configured. Exit
code 2 means nothing is configured yet: relay the printed steps and point to
`DRIVE-SETUP.md`. Do not try to install or configure rclone yourself; `sudo`, downloads
and interactive commands are blocked for Claude on this machine. Never upload the
`.tex` or the posting.

## Files

| File | Purpose |
|------|---------|
| `scripts/build-letter.sh` | latexmk build into `letters/out/`, removes aux files, page count, CV overlap line |
| `scripts/check-overlap.py` | called by the build script; word runs the letter PDF shares verbatim with the CV PDF |
| `scripts/push-to-drive.sh` | upload the PDF to Google Drive (rclone, or synced folder) |
| `DRIVE-SETUP.md` | one-time rclone setup with every prompt answered |
