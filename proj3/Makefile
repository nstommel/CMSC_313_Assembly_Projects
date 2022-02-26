
# Linker flags
LDFLAGS=-g -melf_i386

# Makefile pattern-matching with automatic variables, invoked when
# .o object file target is needed, assembles .asm files.
%.o: %.asm
	nasm -g -f elf -l $*.lst $< -o $@

# Linked executable
TARGET1=main3.out
TARGET2=mytest3.out

# Object .o files
OBJS1=prt_dec.o main3.o
OBJS2=prt_dec.o mytest3.o

all: ${TARGET1} ${TARGET2}

${TARGET1}: ${OBJS1}
	${LD} ${LDFLAGS} ${OBJS1} -o ${TARGET1}

${TARGET2}: ${OBJS2}
	${LD} ${LDFLAGS} ${OBJS2} -o ${TARGET2}

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
	scp prt_dec.asm main3.asm mytest3.asm Makefile stommel1@gl.umbc.edu:~/313/proj3

.PHONY: submit
submit:
	submit cs313_park proj3 prt_dec.asm mytest3.asm typescript


