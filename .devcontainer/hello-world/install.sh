#/bin/bash

PROJECT_ROOT=${1:-"/workspaces/fhel"}

PROJECT_SRC=$PROJECT_ROOT/examples/hello_world

SEAL_SRC=$PROJECT_ROOT/src/backend/seal
SEAL_INSTALL_DIR=${2:-"/tmp/seal"}

# Allow thirdparty libraries from git
git config --global --add safe.directory $SEAL_SRC/build/thirdparty/msgsl-src
git config --global --add safe.directory $SEAL_SRC/build/thirdparty/zlib-src
git config --global --add safe.directory $SEAL_SRC/build/thirdparty/zstd-src

# Trust project
git config --global --add safe.directory $PROJECT_ROOT

# C Build
# cmake -S . -B linux -DSEAL_BUILD_SEAL_C=ON -DSEAL_BUILD_STATIC_SEAL_C=OFF

cd $SEAL_SRC

# C++ Build
cmake -S . -B $SEAL_INSTALL_DIR -DBUILD_SHARED_LIBS=ON
cmake --build $SEAL_INSTALL_DIR

# Install SEAL to $INSTALL
sudo cmake --install $SEAL_INSTALL_DIR

# Compile Hello World Package
cd $PROJECT_SRC
cmake -S . -B build
cmake --build build