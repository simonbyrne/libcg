ifeq ($(OS),Windows_NT)     # is Windows_NT on XP, 2000, 7, Vista, 10...
    OS := Windows
else
    OS := $(shell uname)  # same as "uname -s"
endif
$(info $(OS) detected)

JULIA ?= julia
JULIA_DIR := $(shell $(JULIA) --startup-file=no -e 'print(dirname(Sys.BINDIR))')
DLEXT := $(shell $(JULIA) --startup-file=no -e 'using Libdl; print(Libdl.dlext)')
ADD_JULIA_INTERNAL := $(shell $(JULIA) --startup-file=no -e 'print(VERSION >= v"1.6.0-DEV.1673")')

OUTDIR := ${CURDIR}/target
LIBDIR := $(OUTDIR)/lib
LIBCG := libcg.$(DLEXT)
LIB_LIBCG = $(LIBDIR)/$(LIBCG)
INCLUDE_DIR = $(OUTDIR)/include
LIBCG_INCLUDES = $(INCLUDE_DIR)/julia_init.h $(INCLUDE_DIR)/cg.h

MAIN := $(OUTDIR)/main

ifeq ($(OS), Windows)
  MAIN := $(LIBDIR)/main.exe
endif

.DEFAULT_GOAL := $(MAIN)

WLARGS := -Wl,-rpath,"$(LIBDIR)"

ifeq ($(ADD_JULIA_INTERNAL), true)
  WLARGS += -Wl,-rpath,"$(LIBDIR)/julia"
endif

ifeq ($(OS), Darwin)
  WLARGS += -Wl,-rpath,"@executable_path"
else ifneq ($(OS), Windows)
  WLARGS += -Wl,-rpath,"$$ORIGIN"
endif

ifeq ($(ADD_JULIA_INTERNAL), true)
  LIB_JULIA_INTERNAL := -L$(LIBDIR)/julia -ljulia-internal
endif

CFLAGS+=-O2 -fPIE -I$(JULIA_DIR)/include/julia -I$(INCLUDE_DIR)
LDFLAGS+=-lm -L$(LIBDIR) -ljulia $(LIB_JULIA_INTERNAL) $(WLARGS)

$(LIB_LIBCG) $(LIBCG_INCLUDES): build/build.jl src/CG.jl build/generate_precompile.jl build/additional_precompile.jl
	$(JULIA) --startup-file=no --project=. -e 'using Pkg; Pkg.instantiate()'
	$(JULIA) --startup-file=no --project=build -e 'using Pkg; Pkg.instantiate()'
	OUTDIR=$(OUTDIR) $(JULIA) --startup-file=no --project=build $<

main.o: main.c $(LIBCG_INCLUDES)
	$(CC) $< -c -o $@ $(CFLAGS)

$(MAIN): main.o $(LIB_LIBCG)
	$(CC) -o $@ $< $(LDFLAGS) -lcg
ifeq ($(OS), Darwin)
	# Make sure we can find and use the shared library on OSX
	install_name_tool -change $(LIBCG) @rpath/$(LIBCG) $@
endif
ifeq ($(OS), Windows)
  ifeq ($(ADD_JULIA_INTERNAL), true)
	echo "Please add $(LIBDIR) and $(LIBDIR)/julia to your PATH before running $(MAIN)"
  else
	echo "Please add $(LIBDIR) to your PATH before running $(MAIN)"
  endif
endif

.PHONY: clean
clean:
	$(RM) *~ *.o *.$(DLEXT) main
	$(RM) -Rf $(OUTDIR)
