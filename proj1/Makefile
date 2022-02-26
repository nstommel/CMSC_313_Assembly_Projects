
# Linker flags
LDFLAGS=-g -melf_i386

# Makefile pattern-matching with automatic variables, invoked when
# .o object file target is needed, assembles .asm files.
%.o: %.asm
	nasm -g -f elf -l $*.lst $< -o $@

# Linked executable
TARGET=rot13.out

# Object .o files
OBJS=rot13.o

${TARGET}: ${OBJS}
	${LD} ${LDFLAGS} ${OBJS} -o ${TARGET}


.PHONY: clean
clean:
	rm -f *.o *.out *.lst

.PHONE: mem-check
mem-check: ${TARGET}
	valgrind ./${TARGET}

.PHONY: run
run: ${TARGET}
	./${TARGET}

.PHONY: upload
upload:
	scp rot13.asm Makefile stommel1@gl.umbc.edu:~/313/proj1

.PHONY: submit
submit:
	submit cs313_park proj1 rot13.asm


