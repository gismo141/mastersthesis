set(TEMPLATE ../../../../../Dropbox/mackup/.pandoc/templates/template.latex)
set(BIBLIOGRAPHY ../../../../../Dropbox/mackup/bibtex/library.bib)

add_document(
	Masterarbeit.pdf
	SOURCES				format.yml Masterarbeit.md
	RESOURCE_FILES		${BIBLIOGRAPHY}
	RESOURCE_DIRS		../Diagrams ../Images ../Additions
	PANDOC_DIRECTIVES 	-s
						-N
						--template=template.latex
						--bibliography=library.bib
						--biblatex
						--listings
						--toc
						--latex-engine-opt=-shell-escape
						-f markdown+raw_tex+abbreviations
						--chapters
	PRODUCT_DIRECTORY	.
)