set(TEMPLATE t_thesis.tex)
set(BIBLIOGRAPHY library.bib)
set(BIBPATH ../../../bibtex)

add_document(
    Anhang.tex
    SOURCES             Anhang.md
    RESOURCE_DIRS       appendix-figs
    PANDOC_DIRECTIVES   -t latex
    					--chapters
    NO_EXPORT_PRODUCT
    )

add_document(
	Masterarbeit.pdf
	SOURCES				format.yml Masterarbeit.md
	RESOURCE_FILES		${BIBPATH}/${BIBLIOGRAPHY}
	RESOURCE_DIRS		../Images ../Additions
	PANDOC_DIRECTIVES 	--template=${TEMPLATE}
						--bibliography=${BIBLIOGRAPHY}
						--biblatex
						#--filter ~/Library/Haskell/bin/pandoc-crossref
						--listings
						--toc
						--chapters
						--include-after-body=Anhang.tex
    DEPENDS             Anhang.tex
	PRODUCT_DIRECTORY	.
)