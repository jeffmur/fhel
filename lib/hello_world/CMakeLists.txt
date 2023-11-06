# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.

cmake_minimum_required(VERSION 3.13)

project(P2P VERSION 1.0.0 LANGUAGES CXX)

find_package(SEAL 4.1 REQUIRED)

# libhello.so
add_library(hello SHARED hello.cpp hello.def)
target_link_libraries(hello PRIVATE SEAL::seal_shared)

set_target_properties(hello PROPERTIES
    PUBLIC_HEADER hello.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "hello"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)

# hello_world executable
add_executable(hello_world hello.cpp)
target_link_libraries(hello_world PRIVATE SEAL::seal_shared)

target_sources(hello_world PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/hello.cpp
)