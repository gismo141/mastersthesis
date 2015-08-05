set(TEMPLATE t_thesis.tex)
set(BIBLIOGRAPHY "$ENV{HOME}/bibtex/library.bib")
set(MASTERTHESIS Masterarbeit.md)

add_document(
    Anhang.tex
    SOURCES             Anhang.md
    RESOURCE_DIRS       appendix-figs
    PANDOC_DIRECTIVES   -t latex
    					--chapters
    NO_EXPORT_PRODUCT
)

add_document(
	Masterarbeit.tex
	SOURCES				format.yml ${MASTERTHESIS}
	RESOURCE_FILES		../Images/athene.pdf
	RESOURCE_DIRS		../Additions ../Images
	PANDOC_DIRECTIVES 	-t latex
						--smart
						--self-contained
						--template ${TEMPLATE}
						--filter pandoc-eqnos
						--filter pandoc-fignos
						--filter pandoc-tablenos
						--biblatex
						--bibliography ${BIBLIOGRAPHY}
						--listings
						--toc
						-Vlof
						-Vlot
						--chapters
						--include-after-body=Anhang.tex
    DEPENDS             Anhang.tex
    NO_EXPORT_PRODUCT
    EXPORT_PDF
)