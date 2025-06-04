AS = /usr/bin/nasm
CC = /usr/bin/gcc
LD = gcc

ASFLAGS = -g -f elf64
LDFLAGS = -ljpeg

SRC_DIR = ../src
FILES = main.c mirror_horizontal.s
SRCS = $(addprefix $(SRC_DIR)/, $(FILES))
OBJS = $(patsubst %.s, %.o, $(filter %.s , $(SRCS)))
C_FILES = $(filter %.c , $(SRCS))


EXE = run

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(notdir $(OBJS)) $(C_FILES) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $(notdir $@)
