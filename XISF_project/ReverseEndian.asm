; an x86 assembly langauge snippet to reverse the endian of a 16-bit word
; the argument is passed and returned in EBX 
; EDX is a scratch register that does not need to be preserved

MOV       EDX, EBX
AND       EBX, 000000FF
PUSH      EBX
SHR       EDX, 08
AND       EDX, 000000FF
POP       EBX
SHL       EBX, 08
OR        EBX, EDX