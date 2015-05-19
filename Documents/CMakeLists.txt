set(TEMPLATE template.latex)
set(BIBLIOGRAPHY library.bib)
set(BIBPATH ../../../../../bibtex)

add_document(
	Masterarbeit.pdf
	SOURCES				format.yml Masterarbeit.md
	RESOURCE_FILES		${BIBPATH}/${BIBLIOGRAPHY}
	RESOURCE_DIRS		../Images ../Additions
	PANDOC_DIRECTIVES 	--template=${TEMPLATE}
						--bibliography=${BIBLIOGRAPHY}
						--biblatex
						--filter ~/.cabal/bin/pandoc-crossref
						--listings
						--toc
						--chapters
	PRODUCT_DIRECTORY	.
)

add_document(
	Masterarbeit.docx
	SOURCES				Masterarbeit.md
	RESOURCE_FILES		${BIBPATH}/${BIBLIOGRAPHY}
	RESOURCE_DIRS		../Images ../Additions
	PANDOC_DIRECTIVES 	--filter pandoc-citeproc
						--filter ~/.cabal/bin/pandoc-crossref
						--biblio ${BIBLIOGRAPHY}
						--listings
						--toc
						--chapters
	PRODUCT_DIRECTORY	.
)
