title Number entry program      (Template.asm)

; Duncan Lamb
; CPEN 3710
; October 7, 2025
;


INCLUDE Irvine32.inc

.data
    promptExit BYTE "Enter the exit code: ", 0                                          ; Prompt for exit code input
    promptNum BYTE "Enter a number: ", 0                                                ; Prompt for number input
    msgPos BYTE " is a positive number.", 0Dh, 0Ah, 0                                   ; Message for positive number
    msgNeg BYTE " is a negative number.", 0Dh, 0Ah, 0                                   ; Message for negative number
    msgEven BYTE " is an even number.", 0Dh, 0Ah, 0                                     ; Message for even number
    msgOdd BYTE " is an odd number.", 0Dh, 0Ah, 0                                       ; Message for odd number
    msgLess BYTE " has an absolute value less than 500.", 0Dh, 0Ah, 0                   ; Message for abs < 500
    msgMore BYTE " does not have an absolute value less than 500.", 0Dh, 0Ah, 0         ; Message for abs >= 500
    msgExit BYTE "You entered the exit code. It was ", 0                                ; Message shown for exit
    exitCode SDWORD ?                                                                   ; Storage for whatever number is chosen to be the exit code
    num SDWORD ?                                                                        ; Storage for user input number

.code
print_num PROC                                                                          ; This procedure prints the number with appropriate sign
    mov eax, num
    cmp eax, 0
    jg positive_sign                                                                    ; (Jump if greater) Jump if number is positive
    jl negative_sign                                                                    ; (Jump if lesser) Jump if number is negative                                                                                    
    call WriteInt
    ret
positive_sign:
    mov al, '+'                                                                         ; Add '+' sign to signify positive
    call WriteChar
    mov eax, num
    call WriteDec                                                                       ; Print the positive number
    ret
negative_sign:
    mov eax, num
    call WriteInt                                                                       ; Print negative number as is
    ret
print_num ENDP

main PROC
    ; Main program logic
    mov edx, OFFSET promptExit                                                          ; Display exit code prompt
    call WriteString
    call ReadInt                                                                        ; Read exit code
    mov exitCode, eax

loop_start:                                                                             ; This loop will continue checking for certain properties from the user inputed number
    mov edx, OFFSET promptNum                                                           ; Display number prompt
    call WriteString
    call ReadInt                                                                        ; Read input number
    mov num, eax
    cmp eax, exitCode                                                                   ; Compare with exit code
    je exit_program                                                                     ; (Jump if equal) Jump to exit if num and exitCode match

    ; Check sign
    mov eax, num
    cmp eax, 0
    jl is_negative                                                                      ; (Jump if lesser) Jump if sign is negative
    call print_num
    mov edx, OFFSET msgPos                                                              ; Display positive message
    call WriteString
    jmp parity_check
is_negative:
    call print_num
    mov edx, OFFSET msgNeg                                                              ; Display negative message
    call WriteString

parity_check:
    mov eax, num
    test eax, 1                                                                         ; Check least significant bit for odd/even
    jz is_even                                                                          ; Jump if even
    call print_num
    mov edx, OFFSET msgOdd                                                              ; Display message indicating number is odd
    call WriteString
    jmp abs_check
is_even:
    call print_num
    mov edx, OFFSET msgEven                                                             ; Display message indicating number is even
    call WriteString

abs_check:
    mov eax, num
    mov ebx, eax
    cmp ebx, 0
    jge abs_positive                                                                    ; (Jump greater or equal) Jump if non-negative
    neg ebx                                                                             ; Take absolute value if negative
abs_positive:
    cmp ebx, 500
    jl is_less                                                                          ; (Jump if less) Jump if abs < 500
    call print_num
    mov edx, OFFSET msgMore                                                             ; Display message if abs >= 500
    call WriteString
    jmp loop_continue
is_less:
    call print_num
    mov edx, OFFSET msgLess                                                             ; Display message if abs < 500
    call WriteString

loop_continue:
    call Crlf                                                                           ; New line
    jmp loop_start                                                                      ; Repeat loop

exit_program:
    mov edx, OFFSET msgExit                                                             ; Display exit message
    call WriteString
    mov eax, exitCode
    call WriteInt                                                                       ; Display the exit code
    call Crlf
    exit                                                                                ; End program
main ENDP
END main