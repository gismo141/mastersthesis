add_custom_target(kalibrierungImSC ALL
	COMMAND /usr/local/bin/dot -Tpdf ${CMAKE_CURRENT_SOURCE_DIR}/kalibrierungImSC.dot -o ${CMAKE_CURRENT_BINARY_DIR}/kalibrierungImSC.pdf
)

add_custom_target(kalibrierungImSCmitKorr ALL
	COMMAND /usr/local/bin/dot -Tpdf ${CMAKE_CURRENT_SOURCE_DIR}/kalibrierungImSCmitKorr.dot -o ${CMAKE_CURRENT_BINARY_DIR}/kalibrierungImSCmitKorr.pdf
)

add_custom_target(kalibrierungImWC ALL
	COMMAND /usr/local/bin/dot -Tpdf ${CMAKE_CURRENT_SOURCE_DIR}/kalibrierungImWC.dot -o ${CMAKE_CURRENT_BINARY_DIR}/kalibrierungImWC.pdf
)

add_custom_target(kalibrierungImWCmitKorr ALL
	COMMAND /usr/local/bin/dot -Tpdf ${CMAKE_CURRENT_SOURCE_DIR}/kalibrierungImWCmitKorr.dot -o ${CMAKE_CURRENT_BINARY_DIR}/kalibrierungImWCmitKorr.pdf
)

add_custom_target(kalibrierungImSCSVG ALL
	COMMAND /usr/local/bin/dot -Tsvg ${CMAKE_CURRENT_SOURCE_DIR}/kalibrierungImSC.dot -o ${CMAKE_CURRENT_BINARY_DIR}/kalibrierungImSC.svg
)

add_custom_target(kalibrierungImSCmitKorrSVG ALL
	COMMAND /usr/local/bin/dot -Tsvg ${CMAKE_CURRENT_SOURCE_DIR}/kalibrierungImSCmitKorr.dot -o ${CMAKE_CURRENT_BINARY_DIR}/kalibrierungImSCmitKorr.svg
)

add_custom_target(kalibrierungImWCSVG ALL
	COMMAND /usr/local/bin/dot -Tsvg ${CMAKE_CURRENT_SOURCE_DIR}/kalibrierungImWC.dot -o ${CMAKE_CURRENT_BINARY_DIR}/kalibrierungImWC.svg
)

add_custom_target(kalibrierungImWCmitKorrSVG ALL
	COMMAND /usr/local/bin/dot -Tsvg ${CMAKE_CURRENT_SOURCE_DIR}/kalibrierungImWCmitKorr.dot -o ${CMAKE_CURRENT_BINARY_DIR}/kalibrierungImWCmitKorr.svg
)