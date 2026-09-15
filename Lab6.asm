TITLE Array Sorting Program   (Template.asm)

; Duncan Lamb
; CPEN 3710
; October 23, 2025
;
; This program sorts arrays of signed word integers in ascending order
; and calculates the largest value, mean, and midrange of each array.
;

INCLUDE Irvine32.inc

.data
array1 SWORD 26890, 9918, -2862, -7704, 21185, -15566, 16309, 1650, -7213, 5701
count1 DWORD 10

array2 SWORD 20645, -21917, 29374, 27478, 159, -32228, 7939, -1396, -22011, -32439, -1531, -31470, -24850, -3947, -3718
count2 DWORD 15

msgUnsorted BYTE "Unsorted array:", 0                                   ; Output message strings
msgLargest BYTE "The largest signed value in the array is: ", 0
msgMean BYTE "The mean of the array is: ", 0
msgMidrange BYTE "The midrange of the array is: ", 0
msgSorted BYTE "Sorted array:", 0

.code
main PROC
    call Crlf                       ;Process Array 1
    mov edx, OFFSET msgUnsorted
    call WriteString
    call Crlf
    
    push OFFSET array1              ; Print unsorted array 1
    push count1                     ; Push count to stack
    call PrintArray
    
    push OFFSET array1              ; Sorts array one by passing the adress to the stack
    push count1                     ; Then passes the count to the stack
    call SortArray                  ; Then returns the largest in eax
    
    mov ebx, eax                    ; Save largest value into ebx
    mov edx, OFFSET msgLargest
    call WriteString
    mov eax, ebx                    ; Restore the largest value
    call WriteInt
    call Crlf
    
    push OFFSET array1              ; Calculates mean and midrange for array 1 by passing the array address to stack
    push count1                     ; Then passing the count to the stack
    call CalcStats                  ; Then returns the mean in eax and midrange in edx
    
    push eax                        ; Save mean onto stack
    mov edx, OFFSET msgMean
    call WriteString
    pop eax                         ; Restore the mean
    push edx                        ; Save midrange to the stack
    call WriteInt                   ; Display the mean
    call Crlf
    
    mov edx, OFFSET msgMidrange
    call WriteString
    pop eax                         ; Restore midrange from the stack
    call WriteInt
    call Crlf
    
    mov edx, OFFSET msgSorted       ; Print sorted array 1
    call WriteString
    call Crlf
    
    push OFFSET array1              ; Pass array adress onto stack
    push count1                     ; Pass count on the stack
    call PrintArray
    call Crlf
    call Crlf
    
    mov edx, OFFSET msgUnsorted     ; Process Array 2
    call WriteString
    call Crlf
    
    push OFFSET array2              ; Pass array adress on stack
    push count2                     ; Pass count to stack
    call PrintArray                 ; Print unsorted array 2
    
    push OFFSET array2              ; Pass array adress to stack
    push count2                     ; Pass count onto stack
    call SortArray                  ; Returns the largest in eax
    
    mov ebx, eax                    ; Save the largest value to ebx
    mov edx, OFFSET msgLargest
    call WriteString                ; Displays the largest value
    mov eax, ebx
    call WriteInt
    call Crlf
    
    push OFFSET array2              ; Calculate mean and midrange for array 2 by passing adress to stack
    push count2                     ; Then passing count to the stack
    call CalcStats                  ; Then returning mean in eax and midrange in edx
    
    push eax                        ; Saves mean onto the stack
    mov edx, OFFSET msgMean
    call WriteString
    pop eax                         ; Restore mean back from stack
    push edx                        ; Save midrange onto stack
    call WriteInt                   ; Display the mean
    call Crlf
    
    mov edx, OFFSET msgMidrange
    call WriteString                
    pop eax                         ; Restore the midrange from stack
    call WriteInt                   ; Display the midrange
    call Crlf
    
    mov edx, OFFSET msgSorted
    call WriteString                ; Prints sorted array 2
    call Crlf
    
    push OFFSET array2              ; Passes the aray adress onto the stack
    push count2                     ; Pass count onto the stack
    call PrintArray
    call Crlf
    
    exit
main ENDP

;-----------------------------------------------------------
; SortArray: Bubble sort for signed word array
; Receives: [EBP+12] for the array address, [EBP+8] for the count
; Returns: EAX as the largest element
;-----------------------------------------------------------
SortArray PROC
    push ebp
    mov ebp, esp
    push esi
    push ecx
    push edx
    
    mov esi, [ebp+12]               ; Array address
    mov ecx, [ebp+8]                ; Count
    dec ecx                         ; Outer loop iterations
    
L1: push ecx                        ; Save outer counter
    mov edx, esi                    ; Current position
    mov ecx, [ebp+8]
    dec ecx
    
L2: mov ax, [edx]                   ; Current element
    cmp ax, [edx+2]                 ; Compare with next
    jle L3                          ; Skip if in order
    xchg ax, [edx+2]                ; Swap with next
    mov [edx], ax
    
L3: add edx, 2                      ; Next element
    loop L2
    
    pop ecx
    loop L1
    
    mov eax, [ebp+8]                ; Return largest (last element)
    dec eax
    movsx eax, WORD PTR [esi+eax*2]
    
    pop edx
    pop ecx
    pop esi
    pop ebp
    ret 8
SortArray ENDP

;-----------------------------------------------------------
; CalcStats: Calculates the mean and midrange
; Receives: [EBP+12] for the array address, [EBP+8] for the count
; Returns: EAX as the mean, EDX as the  midrange
;-----------------------------------------------------------
CalcStats PROC
    push ebp
    mov ebp, esp
    push esi
    push ecx
    push ebx
    
    mov esi, [ebp+12]               ; Array address
    mov ecx, [ebp+8]                ; Count
    xor eax, eax                    ; Sum = 0
    xor ebx, ebx                    ; Index = 0
    
L1: movsx edx, WORD PTR [esi+ebx*2]
    add eax, edx
    inc ebx
    cmp ebx, ecx
    jl L1
    
    cdq                             ; Sign extend for division
    idiv ecx                        ; Mean = sum / count
    push eax                        ; Save mean
    
                                    ; Midrange = (first + last) / 2
    movsx eax, WORD PTR [esi]       ; First element
    mov ebx, [ebp+8]
    dec ebx
    movsx edx, WORD PTR [esi+ebx*2] ; Last element
    add eax, edx
    cdq
    mov ebx, 2
    idiv ebx
    
    mov edx, eax                    ; EDX = midrange
    pop eax                         ; EAX = mean
    
    pop ebx
    pop ecx
    pop esi
    pop ebp
    ret 8
CalcStats ENDP

;-----------------------------------------------------------
; PrintArray: Print signed word array
; Receives: [EBP+12] for the array address, [EBP+8] for the count
;-----------------------------------------------------------
PrintArray PROC
    push ebp
    mov ebp, esp                    ; Save registers that will be modified
    push esi                        ; Preserve ESI
    push ecx                        ; Preserve ECX
    
    mov esi, [ebp+12]
    mov ecx, [ebp+8]
    
L1: movsx eax, WORD PTR [esi]       ; Get current element with sign extension
    call WriteInt                   ; Display signed integer
    mov al, ' '
    call WriteChar
    add esi, 2                      ; Move pointer to next element (2 bytes for sword)
    loop L1                         ; Decrements ECX and repeat if not zero
    
    call Crlf
    
    pop ecx                         ; Restore ECX
    pop esi                         ; Restore ESI
    pop ebp                         ; Restore base pointer
    ret 8
PrintArray ENDP

END main