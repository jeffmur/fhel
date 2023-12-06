#/bin/bash

PROJECT_ROOT=${1:-"/workspaces/dart-fhe"}

SEAL_SRC=$PROJECT_ROOT/lib
SEAL_INSTALL_DIR=${2:-"/tmp/seal"}

# Allow thirdparty libraries from git
git config --global --add safe.directory $SEAL_SRC/linux/thirdparty/msgsl-src
git config --global --add safe.directory $SEAL_SRC/linux/thirdparty/zlib-src
git config --global --add safe.directory $SEAL_SRC/linux/thirdparty/zstd-src

# Trust project
git config --global --add safe.directory $PROJECT_ROOT

# C Build
# cmake -S . -B linux -DSEAL_BUILD_SEAL_C=ON -DSEAL_BUILD_STATIC_SEAL_C=OFF

cd $SEAL_SRC/SEAL

# C++ Build
cmake -S . -B $SEAL_INSTALL_DIR -DBUILD_SHARED_LIBS=ON
cmake --build $SEAL_INSTALL_DIR

# Install SEAL to $INSTALL
sudo cmake --install $SEAL_INSTALL_DIR

# Hello World Build

cd $PROJECT_ROOT/lib/hello_world

# C++ Build to hello_world/build
cmake -S . -B build
cmake --build build
