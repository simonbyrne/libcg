
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


.DEFAULT_GOAL := main


cg.$(DLEXT): cg.jl build.jl
	julia --startup-file=no --project build.jl

$(MAIN): main.c cg.$(DLEXT)
	$(CC) -o $@ $^ -O2 -fPIE\
         -DJULIAC_PROGRAM_LIBNAME=\"cg.$(DLEXT)\"\
	 -I"$(JULIA_DIR)/include/julia"\
	 -L"$(JULIA_DIR)/lib"\
	 -ljulia\
         $(WLARGS)

.PHONY: clean
clean:
	$(RM) *.dylib *.so *.dll main
