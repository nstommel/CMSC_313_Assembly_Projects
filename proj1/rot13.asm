
;;; File: rot13.asm last updated 02/25/17
;;; Author: Nicholas Stommel
;;; CMSC 313 Spring 2017, Prof. Park
;;; Description: This program prompts for user input and uses the rot13 ciper
;;; to encrypt/scramble the input. The converted text is printed out to the console.

;; Single line macros for readability
%define STDIN 0
%define STDOUT 1
%define SYSCALL_EXIT  1
%define SYSCALL_READ  3
%define SYSCALL_WRITE 4
%define BUFLEN 256

SECTION .data                   ; section containing initialized data

msg1:       db  "Enter string: "    ; reserved prompt
len_msg1:   equ $-msg1              ; length of prompt

msg2:       db  "Original: "        ; reserved message
len_msg2:   equ $-msg2              ; length of message

msg3:	    db	10, "Convert: "     ; reserved message
len_msg3:   equ $-msg3              ; length of message

lf:         db 10                   ; linefeed used in printing (len 1 byte)

msg4:       db  "Read Error", 10    ; read error message
len_msg4:   equ $-msg4              ; length of message
	
SECTION .bss                    ; section containing unitialized data

read_buf:   resb BUFLEN         ; reserve buffer for reading in string
conv_buf:   resb BUFLEN         ; reserve buffer for converted rot13 string
buf_len:    resb 4              ; reserve space for length of string in memory


SECTION .text                   ; section containing code

global _start                   ; make entry point global

_start:                         ; entry point
    nop                         ; no-op keeps gdb happy

	;; prompt for user input
    mov eax, SYSCALL_WRITE      ; specify sys_write syscall
    mov ebx, STDOUT             ; file descriptor 1: stout
    mov ecx, msg1               ; "Enter string: "
    mov edx, len_msg1           ; length of message
    int 80H                     ; kernel call sys_write

	;; obtain user input
    mov eax, SYSCALL_READ       ; specify sys_read syscall
    mov ebx, STDIN              ; file descriptor 0: stdin
    mov ecx, read_buf           ; pass address of buffer for reading
    mov edx, BUFLEN             ; length of buffer
    int 80H                     ; kernel call sys_read

    mov [buf_len], eax          ; save returned string length
    cmp eax, 0                  ; check if any chars read
    jg  read_ok                 ; if more than 0 chars were read, proceed

    ;; if read fails, print error message and exit
    mov eax, SYSCALL_WRITE      ; specify sys_write syscall
    mov ebx, STDOUT             ; file descriptor 1: stdout
    mov ecx, msg4               ; "Read Error\n"
    mov edx, len_msg4           ; length of error message
    int 080h                    ; kernel call sys_write

    jmp exit                    ; skip over program body

read_ok:
    mov ecx, eax                ; use ecx as loop counter
	
	;; filter out entered newline or carriage return
    cmp [read_buf+eax-1], byte 10   ; compare last char to newline
    je remove_newline               ; if char is newline, remove \n
    cmp [read_buf+eax-1], byte 13   ; compare last char to carriage return
    je remove_newline               ; if char is carriage return, remove \r
	
    jmp filtered_newline            ; if end of string is not newline or cr, skip remove

remove_newline:
    sub [buf_len], byte 1       ; subtract one char length from readlen
    dec ecx                     ; subtract one from eax, which is used as counter in loop

filtered_newline:	
	;; Loop over all characters in read string and convert message
    mov esi, read_buf           ; move address of read buffer to esi register
    mov edi, conv_buf           ; move address of output converted buffer to edi reg

scanchar_loop:
    mov bl, [esi]               ; get next letter

isupper:
	;; jump to charcomplete if not alphabetic and to islower is possibly lowercase
    cmp bl, 'A'         ; if the char is less than 'A', it must be nonalpha
    jl charcomplete     ; do nothing, jump to end of loop
    cmp bl, 'Z'         ; if the char is greater than 'Z', it could be a lowercase letter
    jg islower          ; jump to lowercase filter

    cmp bl, 'M'         ; compare char against middle letter of uppercase alphabet
    jle .else           ; if char is greater than 'M', proceed; otherwise, jump to else

    sub bl, byte 13     ; subtract 13 from character
    jmp charcomplete    ; finished, jump to end of loop

.else:
    add bl, byte 13     ; if char is less than or equal to 'M', add 13 to char
    jmp charcomplete    ; finished, jump to end of loop

islower:
	;; jump to charcomplete and write unaltered character if not alphabetic
    cmp bl, 'a'         ; if char is less than 'a' and not uppercase, it must be nonalpha
    jl charcomplete     ; do nothing, jump to end of loop
    cmp bl, 'z'         ; if char is greater than 'z', it must be nonalpha
    jg charcomplete     ; do nothing, jump to end of loop

    cmp bl, byte 'm'    ; compare char against middle letter of lowercase alphabet
    jle .else           ; if char is greater than 'm', proceed; otherwise, jump to else

    sub bl, byte 13     ; subtract 13 from character
    jmp charcomplete    ; finished, jump to end of loop

.else:
    add bl, byte 13     ; if char is less than or equal to 'm', add 13 to char
                        ; jump not needed, case falls through to end of loop

charcomplete:
    mov [edi], bl       ; write character to buffer
    inc esi             ; increment buffer index
    inc edi             ; increment buffer index
    loop scanchar_loop  ; decrement counter in ecx and jump to start of loop until ecx=0

done:
	; prompt for user input
    mov eax, SYSCALL_WRITE      ; specify sys_write syscall
    mov ebx, STDOUT             ; file descriptor 1: stdout
    mov ecx, msg2               ; "Original: "
    mov edx, len_msg2           ; length of message
    int 80H                     ; kernel call sys_write

	; print out original string
    mov eax, SYSCALL_WRITE      ; specify sys_write syscall
    mov ebx, STDOUT             ; file descriptor 1: stdout
    mov ecx, read_buf           ; original read-in string here
    mov edx, [buf_len]          ; length of read-in string
    int 80H                     ; kernel call sys_write

	; print out message
    mov eax, SYSCALL_WRITE      ; specify sys_write syscall
    mov ebx, STDOUT             ; file descriptor 1: stdout
    mov ecx, msg3               ; "\nConvert: "
    mov edx, len_msg3           ; length of message
    int 80H                     ; kernel call sys_write

	; print out converted string
    mov eax, SYSCALL_WRITE      ; specify sys_write syscall
    mov ebx, STDOUT             ; file descriptor 1: stdout
    mov ecx, conv_buf           ; converted rot13 message here
    mov edx, [buf_len]          ; length of read-in string/converted message
    int 80H                     ; kernel call sys_write

	; print out carriage return
    mov eax, SYSCALL_WRITE      ; specify sys_write syscall
    mov ebx, STDOUT             ; file descriptor 1: stdout
    mov ecx, lf                 ; '\n' line feed
    mov edx, 1                  ; length is one char 
    int 80H                     ; kernel call sys_write

exit:
    mov eax, SYSCALL_EXIT       ; specify sys_exit syscall
    mov ebx, 0                  ; exit code success
    int 80H                     ; kernel call sys_exit
