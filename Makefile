# Makefile — freestanding lib -> test app (NASM + GCC)

CC        := gcc
NASM      := nasm

# Compiler flags — freestanding bootstrap friendly
CFLAGS    := -O0 -g3 \
             -ffreestanding -fno-builtin -fno-stack-protector -nostdinc \
             -Iinclude \
             -Wall -Wextra -Wpedantic -Wconversion -Wdouble-promotion \
             -Wno-unused-parameter -Wno-unused-function -Wno-sign-conversion \
             -Wno-switch -Wno-conversion -Wno-unused-but-set-variable

DEPFLAGS = -MMD -MP -MF $(basename $@).d

# Linker flags for freestanding apps
LDFLAGS   := -nostdlib -static -Wl,-e,_start

BUILD_DIR := build
SRC_DIR   := src
TEST_DIR  := test

# Discover sources
SRC_C   := $(shell find $(SRC_DIR) -type f -name '*.c')
SRC_ASM := $(shell find $(SRC_DIR) -type f -name '*.asm')

# Map sources -> objects under build/
OBJ_C   := $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRC_C))
OBJ_ASM := $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.o,$(SRC_ASM))
OBJ_ALL := $(OBJ_C) $(OBJ_ASM)

DEPS := $(OBJ_C:.o=.d)

# Define the startup asm source and its object (adjust if your start file name differs)
START_SRC := $(SRC_DIR)/start.asm
START_OBJ := $(BUILD_DIR)/start.o

# Library info
LIBDIR  := $(BUILD_DIR)/lib
LIBNAME := atlibc.a
LIB     := $(LIBDIR)/$(LIBNAME)

# Test program to build (user asked for test/foo.c)
TEST_SRCS := $(wildcard $(TEST_DIR)/*.c)
TEST_BINS := $(patsubst $(TEST_DIR)/%.c,$(BUILD_DIR)/test/%,$(TEST_SRCS))
TEST_OBJS := $(patsubst $(TEST_DIR)/%.c,$(BUILD_DIR)/test/%.o,$(TEST_SRCS))

.PHONY: all lib test clean run

all: lib test

# Build the static library (exclude the startup object)
lib: $(LIB)

# Library objects = all compiled objects except the start object
LIB_OBJS := $(filter-out $(START_OBJ), $(OBJ_ALL))

$(LIB): $(LIB_OBJS) | $(LIBDIR)
	@mkdir -p $(dir $@)
	@printf "\033[1;36m[AR]\033[0m %s\n" "$@"
	ar rcs $@ $(LIB_OBJS)
	@ranlib $@ || true


# Build each test binary separately
test: $(LIB) $(START_OBJ) $(TEST_BINS)
	@printf "\033[1;34m[TEST]\033[0m All test binaries built.\n"

$(BUILD_DIR)/test/%: $(LIB) $(START_OBJ) $(BUILD_DIR)/test/%.o
	@printf "\033[1;33m[LD]\033[0m %s\n" "$@"
	$(CC) $(LDFLAGS) -o $@ $(START_OBJ) $(BUILD_DIR)/test/$*.o $(LIB)

# Compile test sources to objects
$(BUILD_DIR)/test/%.o: $(TEST_DIR)/%.c | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	@printf "\033[1;32m[CC]\033[0m %s\n" "$<"
	$(CC) $(CFLAGS) -c $< -o $@

# Run all test binaries and check exit code
run: test
	@for bin in $(TEST_BINS); do \
		printf "\033[1;35m[RUN]\033[0m %s\n" "$$bin"; \
		./$$bin; \
		ec=$$?; \
		if [ $$ec -ne 0 ]; then \
			printf "\033[1;31m[FAIL]\033[0m %s exited with code %d\n" "$$bin" "$$ec"; \
			exit $$ec; \
		else \
			printf "\033[1;32m[PASS]\033[0m %s\n" "$$bin"; \
		fi; \
	done

# Generic rules -----------------------------------------------------------

# C -> object
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	@printf "\033[1;32m[CC]\033[0m %s\n" "$<"
	$(CC) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

# ASM -> object (NASM)
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	@printf "\033[1;35m[ASM]\033[0m %s\n" "$<"
	$(NASM) -f elf64 $< -o $@

# Test source compilation (keeps tests separate under build/test/)
$(BUILD_DIR)/test/%.o: $(TEST_DIR)/%.c | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	@echo "[CC] $<"
	$(CC) $(CFLAGS) -c $< -o $@

# Ensure build and lib directories exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(LIBDIR):
	mkdir -p $(LIBDIR)

# Clean
clean:
	rm -rf $(BUILD_DIR)

crun: clean run

-include $(DEPS)