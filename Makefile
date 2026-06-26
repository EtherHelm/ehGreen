# Makefile for ehGreen
# =====================

FC       = gfortran
OPTFLAGS = -O3 -march=native -mtune=native -funroll-loops -ffast-math -flto
FFLAGS   = $(OPTFLAGS) -ffree-line-length-none -fopenmp -J$(BUILD_DIR)
LDFLAGS  = -L$(BIN_DIR) $(OPTFLAGS) -fopenmp

SRC_DIR  = src
EXAM_DIR = examples
BUILD_DIR = build
BIN_DIR   = bin

# Detect OS
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
  LIB_EXT  = so
  LIB_FLAGS = -fPIC -shared
else ifeq ($(UNAME_S),Darwin)
  LIB_EXT  = dylib
  LIB_FLAGS = -fPIC -shared
else
  LIB_EXT  = dll
  LIB_FLAGS = -shared
endif

LIB_NAME = libehgreen.$(LIB_EXT)
LIB_TARGET = $(BIN_DIR)/$(LIB_NAME)

# Source files
SRCS     = $(wildcard $(SRC_DIR)/*.f90)
OBJS     = $(SRCS:$(SRC_DIR)/%.f90=$(BUILD_DIR)/%.o)

.PHONY: all clean lib dirs

all: dirs $(LIB_TARGET)

dirs:
	mkdir -p $(BUILD_DIR) $(BIN_DIR)

$(LIB_TARGET): $(OBJS)
	$(FC) $(LIB_FLAGS) $(FFLAGS) -o $@ $^ $(LDFLAGS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.f90
	mkdir -p $(BUILD_DIR)
	$(FC) $(FFLAGS) -fPIC -c -o $@ $<

lib: $(LIB_TARGET)

benchmark: $(EXAM_DIR)/benchmark.f90 $(LIB_TARGET)
	$(FC) $(FFLAGS) -o $@ $< $(LDFLAGS) -lehgreen

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR) benchmark
