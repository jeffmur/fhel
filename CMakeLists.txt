#[[
Project-level CMake, useful for debugging
* Import additional libraries
* Compile/Debug via CMake Tools plugin
]]
cmake_minimum_required(VERSION 3.13)

project(FHE VERSION 1.0.0 LANGUAGES CXX)

find_package(SEAL 4.1 REQUIRED)

# hello_world executable
add_executable(hello_world src/backend/hello_world/hello.cpp)
target_link_libraries(hello_world PRIVATE SEAL::seal_shared)

target_sources(hello_world PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/src/backend/hello_world/hello.cpp
)