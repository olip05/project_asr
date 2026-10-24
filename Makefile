SHELL := /bin/sh
.SHELLFLAGS := -eu -c

LATEX = latexmk -bibtex -pdf -output-directory=out -use-make

.PHONY: all clean

all: literature_study presentation report

images: images-copy images-build 

images-copy:
	@echo "Copying image PDFs"
	@for f in img/includes/*.pdf; do \
		[ -e "$$f" ] || continue; \
		cp "$$f" "img/$$(basename "$$f")"; \
	done

images-build:
	@echo "Compiling figure TeX files"
	@set -- img/buildScripts/*.tex; \
	[ -e "$$1" ] || exit 0; \
	for f in "$$@"; do \
		name="$$(basename "$$f" .tex)"; \
		mkdir -p logs/img/"$$name"; \
		latexmk -pdf -bibtex \
			-auxdir=logs/img/"$$name" \
			-output-directory=img \
			"$$f"; \
	done

report: images report.pdf

report.pdf: report/report.tex
	$(LATEX) -auxdir=logs/report report/report.tex
	makeglossaries -d logs/report report
	$(LATEX) -auxdir=logs/report report/report.tex

literature_study: images literature_study.pdf

literature_study.pdf: literature_study/literature_study.tex
	$(LATEX) -auxdir=logs/literature_study literature_study/literature_study.tex
	makeglossaries -d logs/literature_study literature_study
	$(LATEX) -auxdir=logs/literature_study literature_study/literature_study.tex

presentation: images presentation.pdf

presentation.pdf: presentation.slides.pdf presentation.withNotes.pdf

%.slides.pdf: presentation/%.tex
	echo "\\def\\dynmode{normal}\\input{presentation/$(<F)}" > "presentation/$@.slides.temp.tex"
	$(LATEX) -auxdir=logs/$@.slides presentation/$@.slides.temp.tex
	mv out/$@.slides.temp.pdf out/$@
	rm presentation/$@.slides.temp.tex

%.withNotes.pdf: presentation/%.tex
	echo "\\def\\dynmode{withNotes}\\input{presentation/$(<F)}" > "presentation/$@.notes.temp.tex"
	$(LATEX) -auxdir=logs/$@.notes presentation/$@.notes.temp.tex
	mv out/$@.notes.temp.pdf out/$@
	rm presentation/$@.notes.temp.tex

clean: 
	rm -f img/*.pdf
	rm -rf logs/*
	rm -rf out/*