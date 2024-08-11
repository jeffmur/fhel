# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.18)

# Project-level configuration.
set(PROJECT_NAME "fhel")
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/../binary.version" PROJECT_VERSION)
string(STRIP "${PROJECT_VERSION}" PROJECT_VERSION)
project(${PROJECT_NAME} LANGUAGES CXX VERSION ${PROJECT_VERSION})

set(LIB_URL "https://github.com/jeffmur/fhel/releases/download")
set(DISABLE_AUTO_BUILD $ENV{FHEL_DISABLE_AUTO_BUILD})

macro(download_and_extract _url _dst_dir)
  file(GLOB _libs "${_dst_dir}/*.so")
  if(NOT _libs)
    get_filename_component(_dst_file "${_url}" NAME)
    set(_dst_file "${_dst_dir}/${_dst_file}")
    if(NOT EXISTS ${_dst_file})
      # download if not exist
      message(STATUS "Downloading ${_url} -> ${_dst_file}")
      file(DOWNLOAD "${_url}" ${_dst_file}
        SHOW_PROGRESS STATUS _rtn TLS_VERIFY OFF TIMEOUT 300
      )
      list(GET _rtn 0 _rtncode)
      if(NOT 0 EQUAL _rtncode)
        message(FATAL_ERROR ${_rtn})
      endif()
    endif(NOT EXISTS ${_dst_file})

    # extract
    message(STATUS "Extracting ${_dst_file}")
    file(ARCHIVE_EXTRACT INPUT "${_dst_file}" DESTINATION ${_dst_dir})
  else()
    message(STATUS "${_libs} exists, no need to download or extract!")
  endif()
endmacro()

if(NOT DISABLE_AUTO_BUILD)
  # Define default architecture
  set(ARCH $ENV{ARCH})
  if(NOT ARCH)
    message(STATUS "Auto-selected architecture: ${ARCH}")
    set(ARCH "x64")
  endif()

  # Print messages
  message(STATUS "Running setup with architecture: ${ARCH}")

  set(LIB_FILENAME "lib${PROJECT_NAME}-linux-${ARCH}.tar.gz")
  set(LIB_RELEASE "${LIB_URL}/v${PROJECT_VERSION}/${LIB_FILENAME}")
  download_and_extract(${LIB_RELEASE} ${CMAKE_CURRENT_SOURCE_DIR})
endif()

file(GLOB dylib "${CMAKE_CURRENT_SOURCE_DIR}/*.so")
if(NOT dylib)
  message(FATAL_ERROR "${PROJECT_NAME} setup failed: not found any .so in ${CMAKE_CURRENT_SOURCE_DIR}")
endif()

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(fhel_bundled_libraries
  ${dylib}
  PARENT_SCOPE
)
