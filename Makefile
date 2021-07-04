ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

JULIA ?= julia
DLEXT := $(shell $(JULIA) --startup-file=no -e 'using Libdl; print(Libdl.dlext)')

PREFIX := $(ROOT_DIR)/target
LIBDIR := $(PREFIX)/lib
BINDIR := $(PREFIX)/bin
MAIN_C := $(BINDIR)/main-c
MAIN_RS := $(BINDIR)/main-rs

ifeq ($(OS), Windows)
  LIBDIR := $(BINDIR)
  MAIN_C := $(BINDIR)/main-c.exe
  MAIN_RS := $(BINDIR)/main-rs.exe
endif

LIBCG := $(LIBDIR)/libcg.$(DLEXT)

SUBDIRS := CG main-c main-rs

.PHONY: all $(SUBDIRS)
all: $(MAIN_C) $(MAIN_RS)
CG: $(LIBCG)
main-c: $(MAIN_C)
main-rs: $(MAIN_RS)

$(LIBCG):
	$(MAKE) -C CG
	PREFIX=$(PREFIX) $(MAKE) -C CG install

$(MAIN_C): $(LIBCG)
	$(MAKE) -C main-c
	PREFIX=$(PREFIX) $(MAKE) -C main-c install

$(MAIN_RS): $(LIBCG)
	$(MAKE) -C main-rs build-release
	PREFIX=$(PREFIX) $(MAKE) -C main-rs install

.PHONY: clean
clean:
	$(MAKE) -C CG clean
	$(MAKE) -C main-c clean
	$(MAKE) -C main-rs clean clean-release

.PHONY: distclean
distclean: clean
	$(MAKE) -C CG distclean
	$(MAKE) -C main-rs distclean
	$(RM) -Rf $(ROOT_DIR)/target

