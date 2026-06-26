# Makefile for benchmark in examples/
# Links against libehgreen.so (or .dylib/.dll) built from ../src

FC       = gfortran
CC       = gcc
OPTFLAGS = -O3 -march=native -mtune=native -funroll-loops -ffast-math -flto
FFLAGS   = $(OPTFLAGS) -ffree-line-length-none -fopenmp
CFLAGS   = $(OPTFLAGS) -fopenmp
LDFLAGS  = -L../bin -Wl,-rpath,$(abspath ../bin) $(OPTFLAGS) -fopenmp

LIB_DIR  = ../bin

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
  LIB_EXT  = so
else ifeq ($(UNAME_S),Darwin)
  LIB_EXT  = dylib
else
  LIB_EXT  = dll
endif

LIB_TARGET = $(LIB_DIR)/libehgreen.$(LIB_EXT)
TARGETS    = benchmark_fortran benchmark_c

.PHONY: all clean

all: $(TARGETS)

benchmark_fortran: benchmark.f90 $(LIB_TARGET)
	$(FC) $(FFLAGS) -o $@ $< $(LDFLAGS) -lehgreen

benchmark_c: benchmark.c $(LIB_TARGET)
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) -lehgreen

clean:
	rm -f $(TARGETS)
