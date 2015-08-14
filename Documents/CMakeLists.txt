set(TEMPLATE t_thesis.tex)
set(BIBLIOGRAPHY "$ENV{HOME}/bibtex/library.bib")
set(CSL "zeitschrift-fur-internationale-beziehungen.csl")
set(MASTERTHESIS Masterarbeit.md)

# add_document(
#     Anhang.tex
#     SOURCES             Anhang.md
#     RESOURCE_DIRS       appendix-figs
#     PANDOC_DIRECTIVES   -t latex
#     					--chapters
#     NO_EXPORT_PRODUCT
# )

add_document(
	Masterarbeit.pdf
	SOURCES				format.yml ${MASTERTHESIS} ${CSL}
	RESOURCE_FILES		../Images/athene.pdf
	RESOURCE_DIRS		../Additions ../Images
	PANDOC_DIRECTIVES 	-t latex
						--smart
						--self-contained
						--listings
						--toc
						-Vlof
						-Vlot
						--chapters
						--template ${TEMPLATE}
						--filter pandoc-eqnos
						--filter pandoc-fignos
						--filter pandoc-tablenos
						--filter pandoc-citeproc
						--csl ${CSL}
						--bibliography ${BIBLIOGRAPHY}
						# --include-after-body=Anhang.tex
    # DEPENDS             Anhang.tex
)