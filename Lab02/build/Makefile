AS = /usr/bin/nasm
LD = /usr/bin/ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

SRC_DIR = ../src
FILES = main.s
SRCS = $(addprefix $(SRC_DIR)/, $(FILES))
OBJS = $(SRCS:.s=.o)

EXE = run

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(notdir $(OBJS)) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $(notdir $@)