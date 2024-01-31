PROJECT_ROOT := $(shell pwd)
DART_SRC ?= $(PROJECT_ROOT)/dart
FHE_LIB_SRC ?= $(PROJECT_ROOT)/src/backend

# Abstraction Layer, e.g. hello_world
AL_INSTALL_DIR ?= $(PROJECT_ROOT)/build

# Clean up all artifacts for this project
.PHONY: clean
clean:
	@echo "Cleaning project..."
	@rm -rf $(AL_INSTALL_DIR)
	@echo "Cleaning dependencies..."
	@cd $(FHE_LIB_SRC); $(MAKE) clean

# Retrive github submodules
.PHONY: trust-project
trust-project:
	@echo "Trusting project...$(PROJECT_ROOT)"
	@git config --global --add safe.directory $(PROJECT_ROOT)
	@git submodule update --init --recursive

# Install dependencies
.PHONY: install-deps
install-deps:
	@cd $(FHE_LIB_SRC); BACKEND=seal $(MAKE) install

# Build helper, e.g hello_world
.PHONY: build-cmake
build-cmake:
	@echo "Building project..."
	@cmake -S . -B $(AL_INSTALL_DIR)
	@cmake --build $(AL_INSTALL_DIR) --config Release

# Install Dependencies and Build Project
.PHONY: build
build: trust-project install-deps build-cmake

.PHONY: ctest
ctest:
	@echo "Testing cpp..."
	@cd $(AL_INSTALL_DIR); ctest

.PHONY: ctest-ci
ctest-ci: build-cmake ctest

# Test Helper
.PHONY: dtest
dtest:
	@echo "Testing dart..."
	@cd $(DART_SRC); $(MAKE) test

# Automate testing for github workflows
.PHONY: dtest-ci
dtest-ci: build-cmake
	@git config --global --add safe.directory /tmp/flutter
	$(MAKE) dart-test
