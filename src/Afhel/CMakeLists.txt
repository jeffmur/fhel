# Assuming the library is named MyLib

# Specify the minimum version for CMake
cmake_minimum_required(VERSION 3.13)

# Create a library, libAlseal.so
add_library(Alseal SHARED
    Afhel.h
    Alseal.h
    Alseal.cpp
)

# Include SEAL dependency
find_package(SEAL 4.1 REQUIRED)
target_link_libraries(Alseal SEAL::seal_shared)

# Properties
set_target_properties(Alseal PROPERTIES
    PUBLIC_HEADER Afhel.h
    VERSION 1
    SOVERSION 1 # SEAL
    OUTPUT_NAME "Afhel"
)

# Include all headers in this directory
target_include_directories(Alseal PUBLIC .)