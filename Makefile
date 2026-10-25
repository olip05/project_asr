SHELL := /bin/sh
.SHELLFLAGS := -eu -c

LATEX = latexmk -bibtex -pdf -output-directory=doc/out -use-make

.PHONY: all clean

all: literature_study presentation report

images: images-copy images-build 

images-copy:
	@echo "Copying image PDFs"
	@for f in doc/img/includes/*.pdf; do \
		[ -e "$$f" ] || continue; \
		cp "$$f" "doc/img/$$(basename "$$f")"; \
	done

images-build:
	@echo "Compiling figure TeX files"
	@set -- doc/img/buildScripts/*.tex; \
	[ -e "$$1" ] || exit 0; \
	for f in "$$@"; do \
		name="$$(basename "$$f" .tex)"; \
		mkdir -p logs/doc/img/"$$name"; \
		latexmk -pdf -bibtex \
			-auxdir=logs/doc/img/"$$name" \
			-output-directory=doc/img \
			"$$f"; \
	done

report: images report.pdf

report.pdf: doc/report/report.tex
	$(LATEX) -auxdir=doc/logs/report doc/report/report.tex
	makeglossaries -d doc/logs/report report
	$(LATEX) -auxdir=doc/logs/report doc/report/report.tex

literature_study: images literature_study.pdf

literature_study.pdf: doc/literature_study/literature_study.tex
	$(LATEX) -auxdir=doc/logs/literature_study doc/literature_study/literature_study.tex
	makeglossaries -d doc/logs/literature_study literature_study
	$(LATEX) -auxdir=doc/logs/literature_study doc/literature_study/literature_study.tex

presentation: images presentation.pdf

presentation.pdf: presentation.slides.pdf presentation.withNotes.pdf

%.slides.pdf: doc/presentation/%.tex
	echo "\\def\\dynmode{normal}\\input{doc/presentation/$(<F)}" > "doc/presentation/$@.slides.temp.tex"
	$(LATEX) -auxdir=doc/logs/$@.slides doc/presentation/$@.slides.temp.tex
	mv doc/out/$@.slides.temp.pdf doc/out/$@
	rm doc/presentation/$@.slides.temp.tex

%.withNotes.pdf: doc/presentation/%.tex
	echo "\\def\\dynmode{withNotes}\\input{doc/presentation/$(<F)}" > "doc/presentation/$@.notes.temp.tex"
	$(LATEX) -auxdir=doc/logs/$@.notes doc/presentation/$@.notes.temp.tex
	mv doc/out/$@.notes.temp.pdf doc/out/$@
	rm doc/presentation/$@.notes.temp.tex

clean: 
	rm -f doc/img/*.pdf
	rm -rf doc/logs/*
	rm -rf doc/out/*