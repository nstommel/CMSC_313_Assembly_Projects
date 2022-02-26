
;;; Project 4
;;; File: bookcmp.asm
;;; Author: Nick Stommel
;;; CMSC 313, Park Section 02
;;; Edited 04/05/17
;;; Description: compares two books, returning -1, 0, or 1 depending on whether
;;; book1 is less than, equal to, or greater than book2. First book years are compared
;;; then book titles are compared by ASCII order.
        
;; offsets of struct fields in base 10
%define AUTHOR_OFFSET  0
%define TITLE_OFFSET   21
%define SUBJECT_OFFSET 54
%define YEAR_OFFSET    68
    
SECTION .data   ; no initialized data needed

SECTION .bss    ; no unitialized data needed
    
SECTION .text   ; code section

    global bookcmp          ; make subroutine/function visible externally
    extern book1, book2     ; tell nasm that book1 and book2 are external variables

bookcmp:
    push ebx    ; save modified registers on stack
    push ecx
    push edx
    push esi
    push edi

    mov ebx, [book1]    ; move address of structure in book pointer to register
    mov ecx, [book2]

yearcmp:    
    mov eax, [ebx + YEAR_OFFSET]    ; move actual year number into register
    mov edx, [ecx + YEAR_OFFSET]
    cmp eax, edx    ; compare two dates
    je titlecmp     ; if dates are equal, jump and compare titles
    jg .else        ; if date 1 is greater than date 2, jump

    ;; book1 year is less than book2 year, return -1
    mov eax, -1
    jmp done

.else:
    ;; book1 year is greater than book2 year, return 1
    mov eax, 1
    jmp done
    
titlecmp:
    lea esi, [ebx + TITLE_OFFSET]   ; move address of beginning of title to register
    lea edi, [ecx + TITLE_OFFSET]
    
cmp_loop:
    mov bl, [esi]   ; move character into register
    mov cl, [edi]

    cmp bl, 0       
    je .process     ; if character is null, break
    cmp bl, cl      
    jne .process    ; if ascii characters are unequal, break
    
    inc esi         ; move to next character
    inc edi

    jmp cmp_loop    ; loop back

.process:
    ;; compare final chars after exiting loop (string ends or chars are different)
    cmp bl, cl      
    jg .greater     ; if char in bl is greater than char in cl, jump to .greater
    jl .lesser      ; if char in bl is less than char in cl, jump to .lesser

    mov eax, 0      ; if final char in bl is equal to char in cl, return 0
    jmp done
    
.greater:
    mov eax, 1      ; return 1, book1 comes after book2
    jmp done
    
.lesser:
    mov eax, -1     ; return -1, book1 comes before book2
    jmp done

done:    
    pop edi         ; restore modified registers from stack
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret             ; return from subroutine, return val in eax
