Title Fibonacci Program      (Template.asm)

; This program performs a fibonacci type calculation with starting numbers of 1,2, and 7
; Duncan Lamb
; CPEN 3710
; September 17, 2025

include Irvine32.inc                 ; only needed if we call Irvine's routines
                                     ; good idea to always insert at top of pgms.

.data
array DWORD 25 DUP(?)                ; Uninitialized array of 25 DWORDs

.code
main PROC
    mov esi, OFFSET array  ; ESI points to start of our

    ; Initialize first three values
    mov DWORD PTR [esi], 1           ; array[0] = 1 (This initialized our starter values)
    mov DWORD PTR [esi + 4], 2       ; array[1] = 2 (offset by 4 bytes because we are using DWORD)
    mov DWORD PTR [esi + 8], 7       ; array[2] = 7 (I had to specify DWORD or i got build errors)

    mov ecx, 22                      ; Loop 22 times to fill remaining 22 elements
    add esi, 12                      ; Move ESI to point to array[3] this is where we start filling the array

fibLoop:
    mov eax, [esi - 12]              ; EAX = array[n-3] (I have to remember that since we are jumping by 4 this means the last 3 items)
    add eax, [esi - 8]               ; Add array[n-2]
    add eax, [esi - 4]               ; Add array[n-1]
    mov [esi], eax                   ; Store in current position array[n]

    add esi, 4                       ; Move to next DWORD
    loop fibLoop                     ; Decrement ECX, loop if >0

    exit                             ; invoke code to terminate the program

main       endp

end        main