OS := $(shell uname)

JULIA ?= julia
JULIA_DIR := $(shell $(JULIA) -e 'print(dirname(Sys.BINDIR))')
DLEXT := $(shell $(JULIA) -e 'using Libdl; print(Libdl.dlext)')
LIB_JULIA_INTERNAL := $(shell $(JULIA) -e 'if VERSION >= v"1.6.0-DEV.1673" print("-ljulia-internal") end')

OUTDIR := ${CURDIR}/target
LIBDIR := $(OUTDIR)/lib
LIBCG := libcg.$(DLEXT)
LIB_LIBCG = $(LIBDIR)/$(LIBCG)
INCLUDE_DIR = $(OUTDIR)/include
LIBCG_INCLUDES = $(INCLUDE_DIR)/julia_init.h $(INCLUDE_DIR)/cg.h

MAIN := main

ifeq ($(OS), WINNT)
  MAIN := $(MAIN).exe
endif

ifeq ($(OS), Darwin)
  WLARGS := -Wl,-rpath,"$(LIBDIR)" -Wl,-rpath,"@executable_path"
else
  WLARGS := -Wl,-rpath,"$(LIBDIR):$$ORIGIN" 
endif

CFLAGS+=-O2 -fPIE -I$(JULIA_DIR)/include/julia -I$(INCLUDE_DIR)
LDFLAGS+=-L$(LIBDIR) $(WLARGS) -lm -ljulia $(LIB_JULIA_INTERNAL)

.DEFAULT_GOAL := $(MAIN)

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
else ifeq ($(OS), WINNT)
	echo "Please add $(LIBDIR) to your PATH before running $(MAIN)"
endif

.PHONY: clean
clean:
	$(RM) *~ *.o *.$(DLEXT) main
	$(RM) -Rf $(OUTDIR)
