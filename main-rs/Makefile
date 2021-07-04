ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

CARGO_TARGET := target
MAIN := main-rs

ifeq ($(OS), Windows)
  MAIN := main-rs.exe
endif

MAIN_DEBUG := $(CARGO_TARGET)/debug/bin/$(MAIN)
MAIN_RELEASE := $(CARGO_TARGET)/release/bin/$(MAIN)

$(MAIN_DEBUG):
	cargo build

$(MAIN_RELEASE):
	cargo build --release

.PHONY: build
build: $(MAIN_DEBUG)

.PHONY: build-release
build-release: $(MAIN_RELEASE)

.PHONY: install
install: $(MAIN_RELEASE)
# NOTE: adjust install location in .cargo/config.toml
	cargo install --path $(ROOT_DIR)

.PHONY: clean
clean:
	cargo clean

.PHONY: clean-release
clean-release:
	cargo clean --release

.PHONY: distclean
distclean: 
	$(RM) -Rf $(CARGO_TARGET)

.PHONY: setup
setup:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

