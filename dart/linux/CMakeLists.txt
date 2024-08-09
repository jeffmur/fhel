# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.18)

# Project-level configuration.
set(PROJECT_NAME "fhel")

project(${PROJECT_NAME} LANGUAGES CXX VERSION 1.0.0)

file(GLOB fhel_libs "${CMAKE_CURRENT_SOURCE_DIR}/*.so")
if(NOT fhel_libs)
  message(FATAL_ERROR "${PROJECT_NAME} setup failed: not found any .so in ${CMAKE_CURRENT_SOURCE_DIR}")
endif()

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(opencv_dart_bundled_libraries
  # Defined in ../src/CMakeLists.txt.
  # This can be changed to accommodate different builds.
  ${fhel_libs}
  PARENT_SCOPE
)
