title Example Protected Mode Program      (Template.asm)

; Duncan Lamb YLH464
; CPEN 3710
; September 11, 2025
;
; This program demonstrates the basics of Intel x86
; 32-bit protected mode programming.
;

include Irvine32.inc                 ; only needed if we call Irvine's routines
                                     ; good idea to always insert at top of pgms.

.code
main PROC

    mov  eax,0C0000h ; EAX = 0C0000h
    add  eax,464h    ; my utc id is ylh464
    sub  eax,60000h  ; Subtract 60000h

     exit
main ENDP
END main