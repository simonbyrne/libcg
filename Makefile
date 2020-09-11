.DEFAULT_GOAL := main


JULIA_DIR := $(shell julia -e 'print(dirname(Sys.BINDIR))')
DLEXT := $(shell julia -e 'using Libdl; print(Libdl.dlext)')


cg.$(DLEXT): cg.jl build.jl
	julia --startup-file=no --project build.jl

main: main.c cg.$(DLEXT)
	$(CC) -DJULIAC_PROGRAM_LIBNAME=\"cg.$(DLEXT)\" -o $@ $^ -O2 -fPIC\
	 -I"$(JULIA_DIR)/include/julia"\
	 -L"$(JULIA_DIR)/lib"\
	 -ljulia\
	 -Wl,-rpath,"$(JULIA_DIR)/lib" -Wl,-rpath,"@executable_path" # MacOS ld doesn't let you use multiple rpaths in one statement

.PHONY: clean
clean:
	rm *.o *.dylib precompile.jl main
