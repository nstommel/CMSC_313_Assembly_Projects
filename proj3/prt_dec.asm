
;;; Project 3
;;; File: prt_dec.asm
;;; Author: Nick Stommel
;;; CMSC 313, Park Section 02
;;; Edited 03/28/17
;;; Description: contains subroutine to print integer number given parameter on stack
    
;; single line macros for readability
%define STDOUT 1
%define SYSCALL_EXIT  1
%define SYSCALL_WRITE 4
%define BUFLEN 10

SECTION .data

SECTION .bss

numbuf: resb BUFLEN     ; buffer for converted number
numlen: resb 4          ; buffer for storing 32-bit number length

SECTION .text

    global prt_dec      ; make subroutine globally visible

;; subroutine prt_dec
prt_dec:
    
    ;; save contents of registers the subroutine will modify
    push eax
    push ebx
    push ecx
    push edx
    push edi

    mov edi, numbuf         ; move address of number buffer to edi
    mov eax, [esp + 24]     ; move value of parameter into register for division
    mov ecx, 0              ; initialize length counter

div_loop:   
    xor edx, edx            ; zero out edx register before division

    mov ebx, 10             ; mov divisor into register
    div ebx                 ; divide by 10

    mov ebx, edx            ; move remainder into ebx
    add ebx, '0'            ; convert remainder to ascii digit
    push ebx                ; save digit on stack
    inc ecx                 ; increment length counter

    cmp eax, 0              ; compare quotient to 0
    je done_div             ; break loop if quotient is 0
    
    jmp div_loop            ; loop
    
done_div:
    mov [numlen], dword ecx     ; save length of number to output
    
;; write to buffer in loop until all digits pushed onto stack are gone
bufwrite_loop:
    pop ebx             ; pop off digit from stack into ebx
    mov [edi], bl       ; write digit to buffer at index edi
    inc edi             ; increment buffer index
    
    loop bufwrite_loop  ; decrements loop counter in ecx and breaks when 0
    

    ;; make single write syscall
    mov eax, SYSCALL_WRITE      ; specify syswrite call
    mov ebx, STDOUT             ; file descriptor 1: stdout
    mov ecx, numbuf             ; pass address of numbuf buffer
    mov edx, [numlen]           ; print number of chars stored in numlen
    int 80H                     ; make kernel call
    
    
    ;; restore modified registers in LIFO order
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ret     ; return from subroutine
