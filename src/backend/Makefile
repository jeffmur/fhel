BACKEND := seal
INSTALL_DIR := /tmp/$(BACKEND)

.PHONY: clean
clean:
	@echo "Cleaning seal..."
	@rm -rf $(SEAL_INSTALL_DIR)

.PHONY: trust
trust:
	@echo "Trusting seal..."
	@git config --global --add safe.directory $(BACKEND)
	@git config --global --add safe.directory $(INSTALL_DIR)/thirdparty/msgsl-src
	@git config --global --add safe.directory $(INSTALL_DIR)/thirdparty/zlib-src
	@git config --global --add safe.directory $(INSTALL_DIR)/thirdparty/zstd-src

.PHONY: build
build: trust
	@echo "Building seal...$(INSTALL_DIR)"
	@cd $(BACKEND); cmake -S . -B $(INSTALL_DIR) -DBUILD_SHARED_LIBS=ON
	@cd $(BACKEND); cmake --build $(INSTALL_DIR)

.PHONY: install
install: build
	@echo "Installing seal...$(INSTALL_DIR)"
	@cd $(BACKEND); sudo cmake --install $(INSTALL_DIR)
