PROJECT_ROOT := $(shell pwd)
DART_SRC ?= $(PROJECT_ROOT)/dart
FHE_LIB_SRC ?= $(PROJECT_ROOT)/src/backend
FLUTTER_EXAMPLE ?= $(PROJECT_ROOT)/example

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
# .PHONY: install-deps
# install-deps:
# 	@cd $(FHE_LIB_SRC); BACKEND=seal $(MAKE) install

# Build helper, e.g hello_world
.PHONY: build-cmake
build-cmake: UNIT_TEST ?= ON
build-cmake:
	@echo "Building project..."
	@cmake -S . -B $(AL_INSTALL_DIR) -DUNIT_TEST=$(UNIT_TEST)
	@cmake --build $(AL_INSTALL_DIR)

# Install Dependencies and Build Project
.PHONY: build
build: trust-project build-cmake

# Generate html dart api docs
.PHONY: docs
docs:
	@cd $(DART_SRC); $(MAKE) docs

# Publish dart package
.PHONY: publish
publish:
	@cd $(DART_SRC); $(MAKE) publish

# Test Abstract Layer (AFHEL)
.PHONY: ctest
ctest:
	@echo "Testing cpp..."
	@cd $(AL_INSTALL_DIR); ctest

# Debug Abstract Layer (AFHEL)
.PHONY: ctest-debug
ctest-debug: build-cmake
	@echo "Debugging cpp..."
	@cd $(AL_INSTALL_DIR); ./seal_test

# SEAL Basics using the Abstraction Layer
.PHONY: seal-basics
seal-basics: build-cmake
	@echo "SEAL basics..."
	@cd $(AL_INSTALL_DIR); ./seal_basics

# Test Implementation Layer (FHE)
.PHONY: dtest
dtest:
	@echo "Testing dart..."
	@cd $(DART_SRC); $(MAKE) test

# Build the flutter example
.PHONY: apk
apk:
	@cd $(FLUTTER_EXAMPLE); flutter build apk

# Automate testing for github workflows
.PHONY: ctest-ci
ctest-ci: build-cmake ctest

.PHONY: dtest-ci
dtest-ci: build-cmake
	@git config --global --add safe.directory /tmp/flutter
	@cd $(DART_SRC); $(MAKE) deps
	$(MAKE) dtest

.PHONY: apk-ci
apk-ci: export UNIT_TEST = OFF # Disable unit test for release
apk-ci: export ANDROID_SDK_ROOT ?= /tmp/android-sdk-linux
apk-ci: build-cmake
	@git config --global --add safe.directory /tmp/flutter
	$(MAKE) apk

# Publish dart package from github workflows
.PHONY: publish-ci
publish-ci: build-cmake
	@git config --global --add safe.directory /tmp/flutter
	@cd $(DART_SRC); $(MAKE) publish-force
