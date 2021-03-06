# This makefile can help you to build test inputs for your deadlocker tool
# and check its results. If you wish to compute results using your tool as
# well, you must define the OVERFLOWER variable below to contain the path
# to your compiled overflower binary. If you wish to compile your own tests,
# set the paths for CLANG and OPT, as well.
#
# To build LLVM assembly files from C source files:
#   make llvmasm
#
# To analyze the inputs using your tool:
#   make analyze
#
# To remove previous output & intermediate files:
#   make clean
#

OVERFLOWER   := ../obj/bin/overflower
CLANG        := clang
OPT          := opt
RM           := /bin/rm
SOURCE_FILES := $(sort $(wildcard c/*.c))
ASM_FILES    := $(addprefix ll/,$(notdir $(SOURCE_FILES:.c=.ll)))
TXT_FILES    := $(addprefix txt/,$(notdir $(ASM_FILES:.ll=.txt)))
BINARIES     := $(addprefix bin/,$(notdir $(ASM_FILES:.ll=)))


all: $(TXT_FILES)
llvmasm: $(ASM_FILES)
analyze: $(TXT_FILES)
bin: $(BINARIES)


ll/%.ll: c/%.c
	$(CLANG) -g -emit-llvm -S $< -o - | $(OPT) -mem2reg -S -o $@

txt/%.txt: ll/%.ll
	$(OVERFLOWER) $< > $@

bin/%: ll/%.ll
	$(CLANG) -g $< -o $@

clean:
	$(RM) -f $(BINARIES) $(TXT_FILES)

veryclean: clean
	$(RM) -f $(ASM_FILES)

