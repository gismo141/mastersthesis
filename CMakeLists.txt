cmake_minimum_required(VERSION 2.8.11)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/pandocology")
include(pandocology)

add_subdirectory(Documents)