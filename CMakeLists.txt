#[[
Project-level CMake, useful for debugging
* Import additional libraries
* Compile/Debug via CMake Tools plugin
]]
cmake_minimum_required(VERSION 3.13)

project(HELLO_WORLD VERSION 1.0.0 LANGUAGES CXX)

find_package(SEAL 4.1 REQUIRED)

# libhello.so
add_library(hello SHARED examples/hello_world/hello.cpp examples/hello_world/hello.def)
target_link_libraries(hello PRIVATE SEAL::seal_shared)

set_target_properties(hello PROPERTIES
    PUBLIC_HEADER examples/hello_world/hello.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "hello"
)

# hello_world executable
add_executable(hello_world examples/hello_world/hello.cpp)
target_link_libraries(hello_world PRIVATE SEAL::seal_shared)

target_sources(hello_world PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/examples/hello_world/hello.cpp
)
