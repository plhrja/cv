# CV #

### Scripts  ###

* *change_locale.sh*
	* Change the localization for both content and section of the given .tex file
	* Example: ```bash change_locale.sh -en CV.tex``` 
* *copy_CV_to_github.io.sh*
	* Copies the given file to the github hosting repo with the flagged suffix
	* Example: ```bash copy_CV_to_github.io.sh -en CV.pdf```
* *publish.sh*
	* Builds the CV and performs a copy to the github hosting repo in both en\_US and fi\_FI locales.

### Cover letter ###

* *CoverLetter_template.tex*
	* Cover letter in the letter mode of the same moderncv class, style and colour scheme as the CV, with the contact info in the footer.
	* Copy it to ```cover-letter-<company>.tex``` (git-ignored) and build with ```lualatex```.
