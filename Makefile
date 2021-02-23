ifeq ($(OS),Windows_NT)     # is Windows_NT on XP, 2000, 7, Vista, 10...
    OS := Windows
else
    OS := $(shell uname)
endif

JULIA ?= julia
JULIA_DIR := $(shell $(JULIA) --startup-file=no -e 'print(dirname(Sys.BINDIR))')
DLEXT := $(shell $(JULIA) --startup-file=no -e 'using Libdl; print(Libdl.dlext)')

OUTDIR := ${CURDIR}/target
BINDIR := $(OUTDIR)/bin
INCLUDE_DIR = $(OUTDIR)/include
LIBDIR := $(OUTDIR)/lib
MAIN := $(BINDIR)/main
LIBCG := libcg.$(DLEXT)

ifeq ($(OS), Windows)
  LIBDIR := $(BINDIR)
  MAIN := $(BINDIR)/main.exe
endif

LIBCG_INCLUDES = $(INCLUDE_DIR)/julia_init.h $(INCLUDE_DIR)/cg.h
LIBCG_PATH := $(LIBDIR)/$(LIBCG)

.DEFAULT_GOAL := $(MAIN)

ifneq ($(OS), Windows)
  WLARGS := -Wl,-rpath,"$(LIBDIR)"
endif

CFLAGS+=-O2 -fPIE -I$(JULIA_DIR)/include/julia -I$(INCLUDE_DIR)
LDFLAGS+=-lm -L$(LIBDIR) -ljulia $(WLARGS)

$(LIBCG_PATH) $(LIBCG_INCLUDES): build/build.jl src/CG.jl build/generate_precompile.jl build/additional_precompile.jl
	$(JULIA) --startup-file=no --project=. -e 'using Pkg; Pkg.instantiate()'
	# Remove the following line when `create_library()` is merged upstream
	$(JULIA) --startup-file=no --project=build -e 'import Pkg; Pkg.add(url="https://github.com/kmsquire/PackageCompiler.jl.git", rev="kms/create_library")'
	$(JULIA) --startup-file=no --project=build -e 'using Pkg; Pkg.instantiate()'
	JULIA_DEBUG=PackageCompiler OUTDIR=$(OUTDIR) $(JULIA) --startup-file=no --project=build $<

main.o: main.c $(LIBCG_INCLUDES)
	$(CC) $< -c -o $@ $(CFLAGS)

$(MAIN): main.o $(LIBCG_PATH)
	mkdir -p $(BINDIR) 2>&1 > /dev/null
	$(CC) -o $@ $< $(LDFLAGS) -lcg

.PHONY: clean
clean:
	$(RM) *~ *.o *.$(DLEXT) main
	$(RM) -Rf $(OUTDIR)
