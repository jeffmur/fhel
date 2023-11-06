#/bin/bash

export SEAL_SRC=/workspaces/flutter_seal/lib
export SEAL_INSTALL_DIR="/tmp/seal"

# Allow thirdparty libraries from git
git config --global --add safe.directory $SEAL_SRC/linux/thirdparty/msgsl-src
git config --global --add safe.directory $SEAL_SRC/linux/thirdparty/zlib-src
git config --global --add safe.directory $SEAL_SRC/linux/thirdparty/zstd-src

# C Build
# cmake -S . -B linux -DSEAL_BUILD_SEAL_C=ON -DSEAL_BUILD_STATIC_SEAL_C=OFF

cd $SEAL_SRC/SEAL

# C++ Build
cmake -S . -B $SEAL_INSTALL_DIR -DBUILD_SHARED_LIBS=ON
cmake --build $SEAL_INSTALL_DIR

# Install SEAL to $INSTALL
sudo cmake --install $SEAL_INSTALL_DIR
