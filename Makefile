
OS := $(shell uname)
DLEXT := $(shell julia -e 'using Libdl; print(Libdl.dlext)')

JULIA_DIR := $(shell julia -e 'print(dirname(Sys.BINDIR))')
MAIN := main

ifeq ($(OS), WINNT)
  MAIN := $(MAIN).exe
endif

.DEFAULT_GOAL := main


cg.$(DLEXT): cg.jl build.jl
	julia --startup-file=no --project build.jl

$(MAIN): main.c cg.$(DLEXT)
ifeq ($(OS), Darwin)
	$(CC) -DJULIAC_PROGRAM_LIBNAME=\"cg.$(DLEXT)\" -o $@ $^ -O2 -fPIE\
	 -I"$(JULIA_DIR)/include/julia"\
	 -L"$(JULIA_DIR)/lib"\
	 -ljulia\
	 -Wl,-rpath,"$(JULIA_DIR)/lib" -Wl,-rpath,"@executable_path"
else
	$(CC) -DJULIAC_PROGRAM_LIBNAME=\"cg.$(DLEXT)\" -o $@ $^ -O2 -fPIE\
	 -I"$(JULIA_DIR)/include/julia"\
	 -L"$(JULIA_DIR)/lib"\
	 -ljulia\
	 -Wl,-rpath,"$(JULIA_DIR)/lib:$$ORIGIN"
endif

.PHONY: clean
clean:
	rm *.o *.dylib precompile.jl main
