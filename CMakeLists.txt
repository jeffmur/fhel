#[[
Project-level CMake, useful for debugging
* Import additional libraries
* Compile/Debug via CMake Tools plugin
]]
cmake_minimum_required(VERSION 3.13)

project(fhel VERSION 1.0.0 LANGUAGES CXX)

# Import Backend Library
find_package(SEAL 4.1 REQUIRED)

# Include header files
include_directories(
    include
    include/backend
)

# libfhel.so/dylib
add_library(fhel SHARED
    src/backend/aseal.cpp
    src/fhe.cpp
)

target_link_libraries(fhel PRIVATE SEAL::seal_shared)

set_target_properties(fhel PROPERTIES
    PUBLIC_HEADER include/fhe.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "fhel"
)

# demo fhel executable
add_executable(fhel_demo examples/demo_fhel/addition.cpp)
target_link_libraries(fhel_demo SEAL::seal_shared)

target_sources(fhel_demo PRIVATE
    src/backend/aseal.cpp
    src/fhe.cpp
)

# Enable Testing
enable_testing()

# Unit Tests
add_test(NAME add_test COMMAND $<TARGET_FILE:fhel_demo>)