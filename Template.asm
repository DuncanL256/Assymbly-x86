TITLE Add and Subtract, Version 2 (AddSub2.asm)

; This program adds and subtracts 32-bit integers
; and stores the result in a variable. Processing
; is done in real-address mode.
; Name: Duncan Lamb YLH464
; CPEN 3710
; Date: 9/10/2025

INCLUDE Irvine32.inc

.data
val1 WORD 02f41h
val2 WORD 0abcdh 	;altered from dword to word since we are using 16 bit
val3 WORD 0F000h	; increased to cause overflow
finalVal WORD ?

.code
main PROC
	
	mov ax,val1 		; 
	add ax,val2 		;
	add ax,val3 		; overflow here
	mov finalVal,ax 	; store the result
	; call DumpRegs       display registers

	exit
main ENDP
END main