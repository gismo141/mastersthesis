set(TEMPLATE t_thesis.tex)
set(BIBLIOGRAPHY "library.bib")
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
	RESOURCE_FILES		../Images/athene.pdf ../Research/library.bib ../Additions/test.yml
	RESOURCE_DIRS		../Additions ../Graphs ../Images
	PANDOC_DIRECTIVES 	--smart
						--self-contained
						--from markdown
						--to latex
						--highlight-style haddock
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
						--citation-abbreviations=Additions/test.yml
						# --include-after-body=Anhang.tex
    # DEPENDS             Anhang.tex
)

add_document(
	Masterarbeit.html
	SOURCES				format.yml ${MASTERTHESIS} ${CSL}
	RESOURCE_FILES		../Images/athene.pdf ../Research/library.bib ../pandoc.css ../github.css ../scholmd-core-latest.css
	RESOURCE_DIRS		../Additions ../Graphs ../Images
	PANDOC_DIRECTIVES 	--smart
						--self-contained
						--from markdown
						--to html
						--highlight-style haddock
						--toc
						--mathml
						-c pandoc.css github.css scholmd-core-latest.css
						--filter pandoc-eqnos
						--filter pandoc-fignos
						--filter pandoc-tablenos
						--filter pandoc-citeproc
						--csl ${CSL}
						--bibliography ${BIBLIOGRAPHY}
)

add_document(
	Masterarbeit.epub
	SOURCES				format.yml ${MASTERTHESIS} ${CSL}
	RESOURCE_FILES		../Images/athene.pdf ../Research/library.bib ../scholmd-core-latest.css
	RESOURCE_DIRS		../Additions ../Graphs ../Images
	PANDOC_DIRECTIVES 	--smart
						--self-contained
						--from markdown
						--to epub3
						--highlight-style haddock
						--toc
						--mathml
						-c scholmd-core-latest.css
						--filter pandoc-eqnos
						--filter pandoc-fignos
						--filter pandoc-tablenos
						--filter pandoc-citeproc
						--csl ${CSL}
						--bibliography ${BIBLIOGRAPHY}
)