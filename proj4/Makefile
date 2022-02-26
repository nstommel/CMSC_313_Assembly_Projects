
sort_books.out: sort_books.o bookcmp.o
	gcc -m32 sort_books.o bookcmp.o -o sort_books.out

sort_books.o: sort_books.c
	gcc -m32 -ansi -Wall -g -c sort_books.c

bookcmp.o: bookcmp.asm
	nasm -f elf -g bookcmp.asm

.PHONY: clean
clean:
	rm -f *.o *.lst *~ *.out

.PHONY: upload
upload:
	scp *.c *.asm *.dat Makefile stommel1@gl.umbc.edu:~/313/proj4/

.PHONY: submit
submit:
	submit cs313_park proj4 sort_books.c bookcmp.asm typescript
