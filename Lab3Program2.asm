TITLE NameReversal, Version 2 (AddSub2.asm)

; This program Revrses a string and capitalizes it
; Name: Duncan Lamb YLH464
; CPEN 3710
; Date: September 18 2025

INCLUDE Irvine32.inc

.data
source BYTE "i@am@cpen@student@duncan@lamb",0 
target BYTE SIZEOF source DUP(?)           ; Buffer for reversed string to go to

.code
main PROC
    mov esi, OFFSET source                 ; ESI to start of source
    add esi, SIZEOF source - 2             ; Move to last character (before the null bit)
    mov edi, OFFSET target                 ; EDI to start of target
    mov ecx, LENGTHOF source - 1           ; ECX = number of characters to copy (excluding the null of course)

reverseLoop:
    mov al, [esi]                          ; Get character from end of source
    sub al, 20h                            ; Converts lowercase to uppercase and the @ symbol to space
    mov [edi], al                          ; Store in target
    dec esi                                ; Move back in source
    inc edi                                ; Move forward in target
    loop reverseLoop                       ; Repeat until done

    mov BYTE PTR [edi], 0                  ; Add null terminator to our target

                                           ; Display memory dump of both strings
    mov esi, OFFSET source                 ; Start at source
    mov ecx, SIZEOF source + SIZEOF target ; Total bytes to dump
    mov ebx, 1                             ; Display as bytes
    call DumpMem

                                           ; Display original string
    mov edx, OFFSET source                 ; Point to source
    call WriteString                       ; Print original string
    call Crlf                              ; New line

                                           ; Display reversed string
    mov edx, OFFSET target                 ; Point to target
    call WriteString                       ; Print reversed string
    call Crlf                              ; New line

	exit
main ENDP
END main