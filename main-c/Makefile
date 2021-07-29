ifeq ($(OS),Windows_NT)     # is Windows_NT on XP, 2000, 7, Vista, 10...
    OS := Windows
else
    OS := $(shell uname)
endif

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

JULIA ?= julia
JULIA_DIR := $(shell $(JULIA) --startup-file=no -e 'print(dirname(Sys.BINDIR))')
DLEXT := $(shell $(JULIA) --startup-file=no -e 'using Libdl; print(Libdl.dlext)')

PREFIX ?= $(ROOT_DIR)/../target
BINDIR := $(PREFIX)/bin
INCLUDE_DIR = $(PREFIX)/include
LIBDIR := $(PREFIX)/lib
MAIN := main-c
LIBCG := libcg.$(DLEXT)

ifeq ($(OS), Windows)
  LIBDIR := $(BINDIR)
  MAIN := main-c.exe
endif

LIBCG_INCLUDES = $(INCLUDE_DIR)/julia_init.h $(INCLUDE_DIR)/cg.h
LIBCG_PATH := $(LIBDIR)/$(LIBCG)

.DEFAULT_GOAL := $(MAIN)

ifneq ($(OS), Windows)
  WLARGS := -Wl,-rpath,"$(LIBDIR)" -Wl,-rpath,"$(LIBDIR)/julia"
endif

CFLAGS+=-O2 -fPIE -I$(JULIA_DIR)/include/julia -I$(INCLUDE_DIR)
LDFLAGS+=-lm -L$(LIBDIR) -ljulia $(WLARGS)

main.o: main.c $(LIBCG_INCLUDES)
	$(CC) $< -c -o $@ $(CFLAGS)

$(MAIN): main.o
	mkdir -p $(BINDIR) 2>&1 > /dev/null
	$(CC) -o $@ $< $(LDFLAGS) -lcg

.PHONY: install
install: $(MAIN)
	cp $(MAIN) $(PREFIX)/bin

.PHONY: clean
clean:
	$(RM) *~ *.o *.$(DLEXT) $(MAIN)
