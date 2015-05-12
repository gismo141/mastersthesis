add_custom_target(kalibrierungImSC ALL
	COMMAND /usr/local/bin/dot -Tpdf kalibrierungImSC.dot -o kalibrierungImSC.pdf
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(kalibrierungImSCohneKorr ALL
	COMMAND /usr/local/bin/dot -Tpdf kalibrierungImSCohneKorr.dot -o kalibrierungImSCohneKorr.pdf
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(kalibrierungImWC ALL
	COMMAND /usr/local/bin/dot -Tpdf kalibrierungImWC.dot -o kalibrierungImWC.pdf
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)