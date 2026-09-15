; Template64.asm - 64-bit code example.

; November 5, 2025
; Duncan Lamb
; 64-bit prime tester

ExitProcess          PROTO
GetTickCount64       PROTO


ReadInt64            PROTO                                          ;Irvine 64 Procedures
WriteInt64           PROTO
WriteString          PROTO
Crlf                 PROTO

.data
prompt        BYTE  "Enter a positive 64 bit integer: ",0           ;Messages for the print out  
checkMsg      BYTE  "Checking for primality: ",0
primeMsg      BYTE  "Number is prime.",13,10,0
notPrimeMsg   BYTE  "Number is not prime. It is divisible by ",13,10,0
timeMsg       BYTE  "Time taken in milliseconds: ",0
newline       BYTE  13,10,0

number        QWORD ?                                               ; The number the user typed
startTime     QWORD ?                                               ; starts the count before the test
elapsed       QWORD ?                                               ; Milliseconds taken
divisor       QWORD ?                                               ; 0 is prime, otherwise shows the divisor

.code
main PROC

inputLoop:
    mov    rdx, OFFSET prompt                                       ; Prompt user for a number
    call   WriteString
    call   ReadInt64                                                ; returns in RAX
    call   Crlf
    mov    number, rax

    cmp    rax, 1                                                   ; Exit if number <= 1
    jle    exitProgram

    mov    rdx, OFFSET checkMsg                                     ; Print "Checking for primality"
    call   WriteString
    mov    rax, number
    call   WriteInt64                                               ; Automatically prints the plus sign
    call   Crlf

    call   GetTickCount64                                           ; Starts the timer, returns in milliseconds
    mov    startTime, rax

    mov    rcx, number                                              ; Checks for primality
    call   IsPrime64                                                ; returns: RAX = 0 (which would be prime) or divisor
    mov    divisor, rax

    call   GetTickCount64                                           ; Stops the Timer
    sub    rax, startTime
    mov    elapsed, rax

    cmp    divisor, 0                                               ; Print result
    jne    printNotPrime

printPrime:
    mov    rdx, OFFSET primeMsg
    call   WriteString                                              ; Writes the string to the console
    jmp    printTime

printNotPrime:
    mov    rdx, OFFSET notPrimeMsg
    call   WriteString
    mov    rax, divisor                                             ; The actual divisor
    call   WriteInt64
    mov    rdx, OFFSET newline
    call   WriteString
    jmp    printTime

printTime:
    mov    rdx, OFFSET timeMsg
    call   WriteString
    mov    rax, elapsed
    call   WriteInt64
    call   Crlf
    call   Crlf                                                        ; Blank line between tests
    jmp    inputLoop                                                   ; Loop forever

exitProgram:
    mov    rcx, 0
    call   ExitProcess

main ENDP


; IsPrime64 – Fast trial division up to square root of n, skips evens
; Input:  RCX = n (2 <= n <= 2^64-1)
; Output: RAX = 0 if prime, else smallest divisor >1

IsPrime64 PROC
    mov    rax, rcx
    cmp    rax, 2
    je     retPrime                                                     ; 2 is prime
    cmp    rax, 3
    je     retPrime                                                     ; 3 is prime
    test   al, 1
    jz     ret2                                                         ; even ? divisible by 2

    mov    r8, 3                                                        ; start divisor
    mov    r9, rax                                                      ; copy n
    shr    r9, 1                                                        ; use the shift to divide n by 2
    inc    r9                                                           ; loop up to n/2 + 1

sqrtLoop:
    cmp    r8, r9
    ja     retPrime                                                     ; passed sqrt(n)

    mov    rax, rcx                                                     ; Divide n by curent divisor
    xor    rdx, rdx
    div    r8                                                           ; RDX = remainder
    test   rdx, rdx
    jz     foundDivisor

    add    r8, 2                                                        ; Try the next odd number
    jmp    sqrtLoop

ret2:
    mov    rax, 2                                                       ; Return divisor
    ret

foundDivisor:
    mov    rax, r8                                                      ; Return the divisor
    ret

retPrime:
    xor    rax, rax                                                     ; 0 = prime
    ret
IsPrime64 ENDP

END                                                                     ; End of Line