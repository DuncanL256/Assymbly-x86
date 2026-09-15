; Duncan Lamb
; CPEN 3710
; Lab 4 - Multiple-Precision Integer Arithmetic
; Date: September 30, 2025

include Irvine32.inc

.data
bigVal1 DB 9fh, 5fh, 0a7h, 0e9h, 7bh, 0b6h, 7ch, 0f3h, 0d9h, 4ah, 05h, 0d7h, 0edh, 09h, 3bh, 0fdh, 0d8h
bigVal2 DB 48h, 6ah, 35h, 8ch, 9ah, 0a3h, 0e8h, 0dbh, 43h, 27h, 0b1h, 31h, 0a6h, 0bah, 0bbh, 96h, 93h
result1 DB 17 DUP(?)

bigVal3 DB 0c5h, 3ah, 34h, 0cdh, 99h, 9ah, 50h, 43h, 5dh, 0f5h, 06h, 40h, 4dh, 0bbh, 46h, 01h, 6ah        
bigVal4 DB 0beh, 36h, 20h, 38h, 3ah, 0fbh, 5ah, 0c9h, 89h, 1ah, 0c2h, 0a2h, 0ebh, 0a9h, 71h, 0a9h, 15h
result2 DB 17 DUP(?)

.code
main PROC
    mov eax, OFFSET bigVal1                                                 ; Load the offset of bigVal1 into eax (first operand for sub)
    mov ebx, OFFSET bigVal2                                                 ; Load the memory offset of bigVal2 into ebx (second operand)
    mov edx, OFFSET result1                                                 ; Load the offset of result1 into edx
    mov ebp, 1                                                              ; Set ebp to 1 to signal subtraction operation
    call secondP                                                            ; Call secondP to perform bigVal1 - bigVal2

    mov eax, OFFSET bigVal3                                                 ; Load the memory offset of bigVal3 into eax (First operand for add)
    mov ebx, OFFSET bigVal4                                                 ; Load the memory offset of bigVal4 into ebx (second operand)
    mov edx, OFFSET result2                                                 ; Load the memory offset of result2 into edx 
    mov ebp, 2                                                              ; Set ebp to 2 to signal addition operation
    call secondP                                                            ; Call secondP to perform bigVal3 + bigVal4

    call DumpRegs
    mov ecx, 17
    mov ebx, 1
    mov esi, OFFSET bigVal1
    call DumpMem                                                             ; This section sends the values to the window for us to see
    mov esi, OFFSET bigVal2
    call DumpMem
    mov esi, OFFSET result1
    call DumpMem
    mov esi, OFFSET bigVal3
    call DumpMem
    mov esi, OFFSET bigVal4
    call DumpMem
    mov esi, OFFSET result2
    call DumpMem

    exit
main ENDP

; Performs addition or subtraction on two 136-bit (17-byte) integers.
; Returns: Result stored at EDX, carry flag may be set if overflow
; Registers changed: AL, ECX, ESI, Carry flag
secondP PROC
    push ebx                                                              ; Preserve ebx to avoid corruption
    mov ecx, 17                                                           ; Process 17 bytes
    mov esi, 0                                                            ; Initializes the index register

    cmp ebp, 2                                                            ; Check to see if addition
    je addition
    jne subtraction                                                       ; Default to subtraction

addition:
    clc                                                                   ; Clear carry for initial carry (This was getting me into trouble for a while)
add_loop:
    cmp esi, 16                                                           ; Check bounds
    ja done                                                               ; Exit if beyond 16
    mov al, [eax + esi]                                                   ; First operand byte
    adc al, [ebx + esi]                                                   ; Add with carry
    mov [edx + esi], al                                                   ; Store result
    inc esi                                                               ; Next byte
    loop add_loop
    jmp done

subtraction:
    clc                                                                   ; Clear carry for initial borrow
sub_loop:
    cmp esi, 16                                                           ; Check bounds
    ja done                                                               ; Exit if beyond 16
    mov al, [eax + esi]                                                   ; First operand byte
    sbb al, [ebx + esi]                                                   ; Subtract with borrow
    mov [edx + esi], al                                                   ; Store result
    inc esi                                                               ; Next byte
    loop sub_loop
    ; Fall through to done

done:
    pop ebx                                                               ; Restore ebx
    ret                                                                   ; Return to main

secondP ENDP
END main

END main