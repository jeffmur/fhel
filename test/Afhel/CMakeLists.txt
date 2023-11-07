# Assuming the library is named MyLib

# Specify the minimum version for CMake
cmake_minimum_required(VERSION 3.13)

# Create an executable
add_executable(test_seal_batch
    seal_batch.cpp)

# Include SEAL Abstraction Layer
target_link_libraries(test_seal_batch Alseal)

# Create an executable
add_executable(test_seal_int
    seal_int.cpp)

# Include SEAL Abstraction Layer
target_link_libraries(test_seal_int Alseal)

# Create an executable
add_executable(test_seal_io
    seal_io.cpp)

# Include SEAL Abstraction Layer
target_link_libraries(test_seal_io Alseal)