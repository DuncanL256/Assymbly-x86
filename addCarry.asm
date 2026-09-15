TITLE Add with Carry     (AddCarry.asm)

; This program adds three 16-bit numbers to produce a carry out.
; Name: [Your Name Here]
; CPEN 3710
; Date: 09/11/2025

INCLUDE Irvine16.inc

.data
val1     WORD 2F41h
val2     WORD ABCDh
val3     WORD F000h  ; Increased to cause overflow
finalVal WORD ?

.code
main PROC
     mov ax,@data        ; Initialize data segment
     mov ds,ax

     mov  ax,val1       ; AX = val1
     add  ax,val2       ; AX += val2
     add  ax,val3       ; AX += val3 (overflow here)
     mov  finalVal,ax   ; Store result

     exit
main ENDP
END main