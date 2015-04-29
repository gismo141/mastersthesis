SOURCE_FOLDER	:= .
BUILD_FOLDER	:= .build
FILE			:= Masterarbeit
TEMPLATE 		:= template.latex
BIBLIOGRAPHY 	:= \\string~/Dropbox/mackup/bibtex/library.bib

all: pandoc
	cd $(BUILD_FOLDER) && latexmk -pdf -shell-escape $(FILE).tex && cp $(FILE).pdf .. && open ../$(FILE).pdf

pandoc: before
	cd $(BUILD_FOLDER) && pandoc -s -N --template=$(TEMPLATE) --bibliography=$(BIBLIOGRAPHY) --biblatex --listings --toc -f markdown+raw_tex --chapters ../*.yml ../$(FILE).md -o $(FILE).tex

before:
	mkdir -p $(BUILD_FOLDER)

clean:
	rm -rf $(BUILD_FOLDER)