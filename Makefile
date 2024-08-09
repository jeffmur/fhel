PROJECT_ROOT := $(shell pwd)
DART_SRC ?= $(PROJECT_ROOT)/dart
FHE_DIST ?= $(PROJECT_ROOT)/dart/bin
FHE_LIB_SRC ?= $(PROJECT_ROOT)/src/backend
FLUTTER_EXAMPLE ?= $(PROJECT_ROOT)/example

# Abstraction Layer, e.g. hello_world
FHE_BUILD_DIR ?= $(PROJECT_ROOT)/build
FHE_RELEASE_DIR ?= $(PROJECT_ROOT)/dist

# Clean up all artifacts for this project
.PHONY: clean
clean:
	@echo "Cleaning project..."
	@rm -rf $(FHE_BUILD_DIR)
	@rm -rf $(FHE_RELEASE_DIR)
	@echo "Cleaning dependencies..."
	@cd $(FHE_LIB_SRC); $(MAKE) clean

# Retrive github submodules
.PHONY: trust-project
trust-project:
	@echo "Trusting project...$(PROJECT_ROOT)"
	@git config --global --add safe.directory $(PROJECT_ROOT)
	@git submodule update --init --recursive

.PHONY: bin
bin:
	@rm -rf $(FHE_DIST)
	@mkdir $(FHE_DIST)

# Install dependencies
# .PHONY: install-deps
# install-deps:
# 	@cd $(FHE_LIB_SRC); BACKEND=seal $(MAKE) install

# Build helper, e.g hello_world
.PHONY: build-cmake
build-cmake: UNIT_TEST ?= ON
build-cmake: bin
	@echo "Building project..."
	@cmake -S . -B $(FHE_BUILD_DIR) -DUNIT_TEST=$(UNIT_TEST)
	@cmake --build $(FHE_BUILD_DIR)
	@cp $(FHE_BUILD_DIR)/libfhel* $(FHE_DIST)/

# Install Dependencies and Build Project
.PHONY: build
build: trust-project build-cmake

# Release helper
.PHONY: dist-cmake
dist-cmake: bin
	@echo "Creating a release from project..."
	@cmake -S . -B $(FHE_RELEASE_DIR)
	@cmake --build $(FHE_RELEASE_DIR)
	# @cp $(FHE_RELEASE_DIR)/libfhel* $(FHE_DIST)/

.PHONY: dist
dist: dist-cmake

.PHONY: dist-ci
dist-ci: OUTPUT_FILE ?= $(FHE_RELEASE_DIR)/libfhel-$(OS)-$(ARCH).tar.gz
dist-ci: OUTPUT_PATH ?= $(FHE_RELEASE_DIR)/$(OUTPUT_FILE)
dist-ci: dist-cmake
	@tar -czvf $(OUTPUT_PATH) $(FHE_RELEASE_DIR)/libfhel*
	@echo "name=$(OUTPUT_FILE)" >> $(GITHUB_OUTPUT)
	@echo "path=$(OUTPUT_PATH)" >> $(GITHUB_OUTPUT)


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
	@cd $(FHE_BUILD_DIR); ctest

# Debug Abstract Layer (AFHEL)
.PHONY: ctest-debug
ctest-debug: build-cmake
	@echo "Debugging cpp..."
	@cd $(FHE_BUILD_DIR); ./seal_test

# SEAL Basics using the Abstraction Layer
.PHONY: seal-basics
seal-basics: build-cmake
	@echo "SEAL basics..."
	@cd $(FHE_BUILD_DIR); ./seal_basics

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
