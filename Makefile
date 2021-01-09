OS := $(shell uname)

JULIA := julia
JULIA_DIR := $(shell $(JULIA) -e 'print(dirname(Sys.BINDIR))')
DLEXT := $(shell $(JULIA) -e 'using Libdl; print(Libdl.dlext)')

OUTDIR := ./target
LIBDIR := $(OUTDIR)/lib
LIBCG := libCG.$(DLEXT)
LIB_LIBCG = $(LIBDIR)/$(LIBCG)
INCLUDE_DIR = $(OUTDIR)/include
LIBCG_INCLUDES = $(INCLUDE_DIR)/julia_init.h $(INCLUDE_DIR)/cg.h

MAIN := main

ifeq ($(OS), WINNT)
  MAIN := $(MAIN).exe
endif

ifeq ($(OS), Darwin)
  WLARGS := -Wl,-rpath,"$(JULIA_DIR)/lib" -Wl,-rpath,"@executable_path"
else
  WLARGS := -Wl,-rpath,"$(JULIA_DIR)/lib:$$ORIGIN"
endif

CFLAGS+=-O2 -fPIE -I$(JULIA_DIR)/include/julia -I$(INCLUDE_DIR)
LDFLAGS+=-L$(JULIA_DIR)/lib -L$(LIBDIR) -ljulia -lm $(WLARGS)

.DEFAULT_GOAL := $(MAIN)

$(LIB_LIBCG) $(LIBCG_INCLUDES): build/build.jl src/CG.jl build/generate_precompile.jl build/additional_precompile.jl
	$(JULIA) --startup-file=no --project=. -e 'using Pkg; Pkg.instantiate()'
	$(JULIA) --startup-file=no --project=build -e 'using Pkg; Pkg.instantiate()'
	OUTDIR=$(OUTDIR) $(JULIA) --startup-file=no --project=build $<

main.o: main.c $(LIBCG_INCLUDES)
	$(CC) $< -c -o $@ $(CFLAGS) -DJULIAC_PROGRAM_LIBNAME=\"$(LIBCG)\"

$(MAIN): main.o $(LIB_LIBCG)
	$(CC) -o $@ $< $(LDFLAGS) -lcg
ifeq ($(OS), Darwin)
	# Make sure we can find and use the shared library on OSX
	install_name_tool -change $(LIBCG) $(LIB_LIBCG) $@
	## Alternatively, if we install the lib directory somewhere in the library
	## search path, we could run
	# install_name_tool -change $(LIBCG) @rpath/$(LIBCG) $@
else ifeq ($(OS), WINNT)
	echo "Please add $(LIBDIR) to your PATH before running $(MAIN)"
else
	echo "Please add $(LIBDIR) to LD_LIBRARY_PATH before running $(MAIN)"
endif

.PHONY: clean
clean:
	$(RM) *~ *.o *.$(DLEXT) main
