PROJECT_ROOT := $(shell pwd)
DART_SRC ?= $(PROJECT_ROOT)/dart
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

# Build helper, e.g hello_world
.PHONY: build-cmake
build-cmake: UNIT_TEST ?= ON
build-cmake: TARGET_DIR ?= $(FHE_BUILD_DIR)
build-cmake:
	@echo "Building project..."
	@cmake -S . -B $(TARGET_DIR) -DUNIT_TEST=$(UNIT_TEST)
	@cmake --build $(TARGET_DIR)

# Install Dependencies and Build Project
.PHONY: build
build: trust-project build-cmake

# Release helper
.PHONY: dist-cmake
dist-cmake: export UNIT_TEST ?= OFF
dist-cmake: export TARGET_DIR ?= $(FHE_RELEASE_DIR)
dist-cmake:
	@make build-cmake

.PHONY: dist
dist: dist-cmake

.PHONY: dist-ci
dist-ci: OUTPUT_FILE ?= libfhel-$(OS)-$(ARCH).tar.gz
dist-ci: OUTPUT_PATH ?= $(FHE_RELEASE_DIR)/$(OUTPUT_FILE)
dist-ci: dist-cmake
	@ls -d $(FHE_RELEASE_DIR)/libfhel* | grep -o '[^/]*$$' | tar -czvf $(OUTPUT_PATH) -C $(FHE_RELEASE_DIR) --files-from=-
	@echo "tar_gz_name=$(OUTPUT_FILE)" >> $(GITHUB_OUTPUT)
	@echo "tar_gz_path=$(OUTPUT_PATH)" >> $(GITHUB_OUTPUT)

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
	@cd $(DART_SRC); $(MAKE) test FHEL_C_LIB_PREFIX=$(FHE_BUILD_DIR)

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
apk-ci: export ANDROID_SDK_ROOT ?= /tmp/android-sdk-linux
apk-ci: export FHEL_DISABLE_AUTO_BUILD = 1
apk-ci:
	@git config --global --add safe.directory /tmp/flutter
	$(MAKE) apk

# Publish dart package from github workflows
.PHONY: publish-ci
publish-ci:
	@git config --global --add safe.directory /tmp/flutter
	@cd $(DART_SRC); $(MAKE) publish-force
