
;;; Project 2
;;; File escapeseqs.asm
;;; Nick Stommel
;;; CMSC 313, Park Section 02
;;; Edited 03/05/17

;; Single line macros for readability
%define STDIN 0
%define STDOUT 1
%define SYSCALL_EXIT  1
%define SYSCALL_READ  3
%define SYSCALL_WRITE 4
%define BUFLEN 512

SECTION .data   ; section containing initialized data

esc_letters:    ; lookup table for letters & corresponding escape sequences
    ;    a   b   c   d   e   f   g
    dd   7,  8, -1, -1, -1, 12, -1
    ;    h   i   j   k   l   m   n
    dd  -1, -1, -1, -1, -1, -1, 10
    ;    o   p   q   r   s   t   u
    dd  -1, -1, -1, 13, -1,  9, -1
    ;    v   w   x   y   z
    dd  11, -1, -1, -1, -1

msg1:   db  "Enter string: ", 0     ; reserved prompt

msg2:   db  "Original: ", 0         ; reserved message

msg3:   db  10, "Convert:  ", 0      ; reserved message

msg4:   db  "READ ERROR", 0         ; error message

msg5:   db  "Unknown escape sequence ", 0           ; error message

msg6:   db  "ERROR: octal value overflow!", 10, 0   ; error message

lf:     db  10, 0                   ; linefeed for printing
    
SECTION .bss    ; section containing unitialized data

readbuf:    resb BUFLEN     ; buffer for reading in data
readlen:    resb 4          ; contains read length
convbuf:    resb BUFLEN     ; buffer for writing converted text
convlen:    resb 4          ; contains converted text buffer length
charbuf:    resb 4          ; small buffer for use in error message printing
    
SECTION .text   ; section containing code

global _start                   ; make entry point global

_start:                         ; entry point
    nop                         ; no-op keeps gdb happy

	;; prompt for user input
    mov eax, msg1      ; print text prompt
    call print
    
	;; obtain user input
    mov eax, SYSCALL_READ       ; specify sys_read syscall
    mov ebx, STDIN              ; file descriptor 0: stdin
    mov ecx, readbuf            ; pass address of buffer for reading
    mov edx, BUFLEN-1           ; length of buffer (subtracted one for null termination)
    int 80H                     ; kernel call sys_read

    mov [readlen], eax          ; save returned string length
    cmp eax, 0                  ; check if any chars read
    jg  read_ok                 ; if more than 0 chars were read, proceed

    ;; if read fails, print error message and exit
    mov eax, msg4               ; print error message
    call print                  ; invoke print subroutine
    jmp exit                    ; skip over program body

read_ok:
	;; read okay, filter out entered newline or carriage return
    cmp [readbuf+eax-1], byte 10    ; compare last char to newline
    je remove_newline               ; if char is newline, remove \n
    cmp [readbuf+eax-1], byte 13    ; compare last char to carriage return
    je remove_newline               ; if char is carriage return, remove \r
	
    jmp filtered_newline            ; if end of string is not newline or cr, skip remove

remove_newline:
    sub [readlen], byte 1           ; decrement buffer length by one, removing newline

filtered_newline:
    mov edx, [readlen]          ; temporarily move readlen into edx for null termination
    mov [readbuf+edx], byte 0   ; null terminate string
    
	;; Loop over all characters in read string and convert message
    mov esi, readbuf           ; move address of read buffer to esi register
    mov edi, convbuf           ; move address of output converted buffer to edi register

scanchar_loop:
    mov al, [esi]   ; move single character into al (if eax is used, 4 chars are moved)
                    ; using 8-bit register is necessary to grab single char
    cmp al, 0       ; have we reached a null character?
    je done         ; if so, break loop

    cmp al, 92      ; compare char against backslash
    jne else        ; skip to else clause if not backslash
    
    inc esi             ; if backslash is present, increment esi before call
    call handle_ESC     ; invoke subroutine handle_ESC (uses esi val and returns eax val)
    jmp charcomplete    ; skip over else clause

else:
    inc esi         ; if not backslash, merely increment esi

charcomplete:
    mov [edi], al           ; move single character (in eax) to index in convbuf
    inc edi                 ; increment index in convbuf
    add [convlen], byte 1   ; increment convbuf length by one char
    jmp scanchar_loop       ; jump back to loop body, will break once '\0' encountered

done:
    mov eax, [convlen]          ; temporarily move convlen into eax for null termination 
    mov [convbuf+eax], byte 0   ; null terminate converted string
    
    mov eax, msg2               ; print message "Original: "
    call print                  ; invoke print subroutine
    
    mov eax, readbuf            ; print out original string
    call print                  ; invoke print subroutine

    mov eax, msg3               ; print message "Convert: "
    call print                  ; invoke print subroutine

    mov eax, convbuf            ; print converted message
    call print                  ; invoke print subroutine
    
    mov eax, lf                 ; print newline after converted message for aesthetics
    call print                  ; invoke print subroutine

exit:
    mov eax, SYSCALL_EXIT       ; specify sys_exit syscall
    mov ebx, 0                  ; exit code success
    int 80H                     ; kernel call sys_exit


;; Subroutine print
print:
    mov ebx, eax            ; use ebx as index (using edi interferes with main scanchar_loop)
    mov edx, 0              ; initialize character count

count_chars:
    cmp [ebx], byte 0       ; have we reached a null character?
    je done_print           ; if so, break loop and print to console                    
    
    inc edx                 ; increment character count
    inc ebx                 ; increment index in buffer
    jmp count_chars         ; loop again

done_print:
    mov ecx, eax            ; pass address of message from eax to ecx
    mov eax, SYSCALL_WRITE  ; specify sys_write syscall
    mov ebx, STDOUT         ; specify file descriptor 1: stdout
                            ; character count already contained in edx
    int 80H                 ; kernel call sys_write

    ret                     ; return, subroutine finished
;; end of print subroutine


;; Subroutine handle_ESC
handle_ESC:
    xor ebx, ebx        ; clear entire 32-bit register ebx before proceeding
    mov bl, [esi]       ; save copy of char in bl, using 8-bit register is necessary to grab single char
    inc esi             ; increment index in readbuf

is_octal:
    cmp bl, '0'         ; compare against lowest octal digit
    jl is_other         ; if char < '0', definitely other character
    cmp bl, '7'         ; compare against highest octal digit
    jg is_backslash     ; if char > '7', could be backslash

    mov eax, ebx        ; use eax in conversion
    sub eax, '0'        ; convert ascii digit to integer
    mov edx, eax        ; initialize total_value in edx
    
    mov ecx, 2          ; initialize loop counter, up to 3 octal digits
    
examine_octal:
    mov bl, [esi]       ; peek at next char, using 8-bit register is necessary to grab single char

    cmp bl, '0'         ; compare against lowest octal digit
    jl process          ; if char < '0', break loop (not octal) and process
    cmp bl, '7'         ; compare against highest octal digit
    jg process          ; if char > '7', break loop (not octal) and process

    inc esi             ; increment index in readbuf


    mov eax, ebx        ; use eax in conversion
    sub eax, '0'        ; convert ascii digit to integer

    shl edx, 3          ; multiply total_value by 8, shifting left by 3
    add edx, eax        ; add digit_value to total_value
    
    loop examine_octal  ; keep looking for octal digits
    
process:
    cmp edx, 255        ; compare total_value to max value allowed
    jg octal_overflow   ; if total_value exceeds 255, octal overflow has occurred

    mov eax, edx        ; return total value if overflow has not occurred
    jmp complete        ; finished

octal_overflow:
    mov eax, msg6       ; print "ERROR: octal value overflow!"
    call print          ; invoke print subroutine
    
    mov eax, 92         ; return backslash for error
    jmp complete        ; finished

is_backslash:
    cmp bl, 92          ; if char is a backslash
    jl is_other         ; definitely other character
    cmp bl, 92          ; if char is a backslash
    jg is_lower         ; possibly lowercase letter

    mov eax, 92         ; char is okay as backslash, return backslash
    jmp complete        ; finished
    
is_lower:
    cmp bl, 'a'         ; compare char against smallest lowercase number
    jl is_other         ; if char < 'a', definitely other character
    cmp bl, 'z'         ; compare char against largest lowercase number
    jg is_other         ; if char > 'z', definitely other character

    sub ebx, 'a'        ; convert lowercase ascii to index in lookup table

    mov eax, [esc_letters + ebx*4]  ; use base+index*scale to access lookup table array
    cmp eax, -1                     ; compare lookup value against -1
    jne complete                    ; if value is valid, return what's in eax and finish

    ;; if value in lookup table is invalid
    
    add ebx, 'a'                    ; restore original character
    push ebx                        ; save character in ebx for error message
    
    mov eax, msg5                   ; print error message
    call print                      ; invoke print subroutine

    pop ebx                         ; restore character to ebx for error message

    mov [charbuf], byte 92      ; move backslash into buffer
    mov [charbuf+1], byte bl    ; move erroneous character into buffer
    mov [charbuf+2], byte 10    ; put newline in buffer
    mov [charbuf+3], byte 0     ; null terminate string
    mov eax, charbuf            ; print "\X\n\0"
    call print                  ; invoke print subroutine
    
    mov eax, 92                 ; return backslash for invalid escape sequence
    jmp complete                ; finished
    
is_other:

    push ebx ; save character in ebx for error message
    
    mov eax, msg5 ; print error message
    call print

    pop ebx ; restore character to ebx for error message
    
    mov [charbuf], byte 92      ; move backslash into buffer
    mov [charbuf+1], byte bl    ; move erroneous character into buffer
    mov [charbuf+2], byte 10    ; put newline in buffer
    mov [charbuf+3], byte 0     ; null terminate string
    mov eax, charbuf            ; print "\X\n\0"
    call print                  ; invoke print subroutine

    mov eax, 92                 ; return backslash for invalid escape sequence

complete:
    ret                         ; finished subroutine, return
;; End of handle_ESC subroutine

    
