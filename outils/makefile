FICHIERS := outils.html outils.pdf

THEME ?= bbb

## affiche la liste des cibles
help:
	@tabs 20 ; sed -rne '/^## /h; /^[^.%#\t][^% ]+:/{ G; s/^(.*):.*##(.*)/\1\t\2/; T fin ; P; :fin z ; h }' $(MAKEFILE_LIST)

## construit tous les fichiers
build: $(FICHIERS)

%.html: %.md bbb.css
	pandoc --embed-resources --standalone --css bbb.css -V lang=fr -V linkcolor=blue $< -o $@

%.pdf: %.md etc/logo-univ-lille.pdf
	$(MAKE) -f etc/makefile-pandoc CONFDIR=etc THEME=$(THEME) FILE=$@ $(TYPE)
	-rm -rf _minted-input

%.pdf: %.svg
	inkscape -d 2400 -o $@ -T $<

## supprime les fichiers inutiles
clean:
	-rm -rf *~ _minted*

## supprime les fichiers inutiles ou regénérables
reset: clean
	-rm $(FICHIERS)

