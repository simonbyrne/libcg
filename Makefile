OS := $(shell uname)
DLEXT := $(shell julia -e 'using Libdl; print(Libdl.dlext)')

JULIA_DIR := $(shell julia -e 'print(dirname(Sys.BINDIR))')
MAIN := main

ifeq ($(OS), WINNT)
  MAIN := $(MAIN).exe
endif

ifeq ($(OS), Darwin)
  WLARGS := -Wl,-rpath,"$(JULIA_DIR)/lib" -Wl,-rpath,"@executable_path"
else
  WLARGS := -Wl,-rpath,"$(JULIA_DIR)/lib:$$ORIGIN"
endif

CFLAGS+=-O2 -fPIE -I$(JULIA_DIR)/include/julia
LDFLAGS+=-L$(JULIA_DIR)/lib -L. -ljulia -lm $(WLARGS)

.DEFAULT_GOAL := main

libcg.$(DLEXT): build.jl lib/cg.jl lib/precompile.jl
	julia --startup-file=no --project build.jl

main.o: main.c
	$(CC) $^ -c -o $@ $(CFLAGS) -DJULIAC_PROGRAM_LIBNAME=\"libcg.$(DLEXT)\"

$(MAIN): main.o libcg.$(DLEXT)
	$(CC) -o $@ $< $(LDFLAGS) -lcg

.PHONY: clean
clean:
	$(RM) *~ *.o *.$(DLEXT) main
