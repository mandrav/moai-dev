cmake_minimum_required(VERSION 2.8.5)
project(tinyxml)

# Check to ensure that we are running as part of the
# root CMakeLists.txt file.
if(NOT DEFINED IS_ROOT)
  message(FATAL_ERROR "You must generate the CMake files as part of the root directory.")
endif(NOT DEFINED IS_ROOT)

set(${PROJECT_NAME}_UnixInclude "${ROOT_DIR}/3rdparty/tinyxml/" PARENT_SCOPE)
set(CMAKE_CURRENT_SOURCE_DIR "${ROOT_DIR}/3rdparty/tinyxml/")

moai_manual(library
    ${CMAKE_CURRENT_SOURCE_DIR}/tinystr.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tinyxml.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tinyxmlerror.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tinyxmlparser.cpp
)