cmake_minimum_required(VERSION 2.8.5)
project(luac)

# Check to ensure that we are running as part of the
# root CMakeLists.txt file.
if(NOT DEFINED IS_ROOT)
  message(FATAL_ERROR "You must generate the CMake files as part of the root directory.")
endif(NOT DEFINED IS_ROOT)

set(CMAKE_CURRENT_SOURCE_DIR "${ROOT_DIR}/3rdparty/lua-5.1.3/src/")

moai_manual(executable
    ${CMAKE_CURRENT_SOURCE_DIR}/luac.c
)
moai_needs(lua-lib)