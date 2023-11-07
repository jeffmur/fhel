#[[
Project-level CMake, useful for debugging
* Import additional libraries
* Compile/Debug via CMake Tools plugin
]]
cmake_minimum_required(VERSION 3.13)

project(Flutter_SEAL VERSION 1.0.0 LANGUAGES CXX)

# libAlseal.so
# Add source files to library and header files to install
add_subdirectory(src/Afhel)

# Add test files
add_subdirectory(test/Afhel)
