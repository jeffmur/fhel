#[[
    Project-level CMake Config
    --------------------------
    * Import / Install backend libraries
    * Compile source code, fhel, into a shared library
    * Used for building the Dart package
    * Enable GoogleTest if UNIT_TEST environment variable is set to ON
]]
cmake_minimum_required(VERSION 3.13)

# Set C++ standard, required by GoogleTest
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(fhel VERSION 1.0.0 LANGUAGES CXX)

# Import Backend Library
add_subdirectory(src/backend/seal)

# find_package(SEAL REQUIRED)

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

target_link_libraries(fhel PUBLIC seal)

set_target_properties(fhel PROPERTIES
    PUBLIC_HEADER include/fhe.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "fhel"
)

target_compile_definitions(fhel PUBLIC DART_SHARED_LIB)

# Use -DUNIT_TEST to override default OFF
set(UNIT_TEST OFF CACHE BOOL "Enable GoogleTest")

# Check if UNIT_TEST variable is set to ON
if(DEFINED UNIT_TEST AND UNIT_TEST STREQUAL "ON")
    enable_testing()

    # Google Test Platform
    include(FetchContent)
    FetchContent_Declare(
        googletest
        URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
    )
    # For Windows: Prevent overriding the parent project's compiler/linker settings
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)

    add_executable(
        seal_test
        # test/seal/context.cpp
        # test/seal/encrypt.cpp
        # test/seal/addition.cpp
        # test/seal/subtraction.cpp
        # test/seal/multiplication.cpp
        # test/seal/relinearization.cpp
        test/seal/exchange.cpp
        test/seal/basics/1_bfv.cpp
        test/seal/basics/3_levels.cpp
        test/seal/basics/4_bgv.cpp
        test/seal/basics/5_ckks.cpp
        test/seal/basics/7_serialization.cpp
    )

    target_link_libraries(
        seal_test
        GTest::gtest_main
        seal
        fhel
    )

    include(GoogleTest)
    gtest_discover_tests(seal_test)

    # SEAL Basics
    add_executable(
        seal_basics
        # test/seal/basics/1_bfv.cpp
        # test/seal/basics/3_levels.cpp
        # test/seal/basics/4_bgv.cpp
        # test/seal/basics/5_ckks.cpp
        test/seal/basics/7_serialization.cpp
    )
    include_directories(test/seal/basics)
    target_link_libraries(
        seal_basics
        GTest::gtest_main
        seal
        fhel
    )
    gtest_discover_tests(seal_basics)
endif()
