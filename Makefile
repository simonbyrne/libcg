JULIA_DIR := $(shell julia -e 'print(dirname(Sys.BINDIR))')
DLEXT = dylib

main: main.c sys.$(DLEXT)
	gcc -DJULIAC_PROGRAM_LIBNAME=\"sys.$(DLEXT)\" -o $@ $^ -O2 -fPIE\
	 -I"$(JULIA_DIR)/include/julia"\
	 -L"$(JULIA_DIR)/lib"\
	 -ljulia\
	 -Wl,-rpath,"$(JULIA_DIR)/lib" -Wl,-rpath,"@executable_path" # MacOS ld doesn't let you use multiple rpaths in one statement

precompile.jl: cg.jl
	julia --startup-file=no --trace-compile=$@ $<

sys.o: custom_sysimg.jl precompile.jl cg.jl
	julia --startup-file=no -J"$(JULIA_DIR)/lib/julia/sys.$(DLEXT)" --output-o $@ $<

sys.$(DLEXT): sys.o
	gcc -shared -o $@ -fPIC -Wl,-all_load $< -Wl -L"$(JULIA_DIR)/lib" -ljulia # this is MacOS specific

