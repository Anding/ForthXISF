; EBX will contain a number of bytes, n.  n%4=0, that is n is divisible by 4
; [EBP] will contain the address of the data buffer
; EAX, ECX, EDX are scratch registers that do not need to be preserved
; if other registers are used they must be preserved

; This code converts 16-bit signed words (-32768 to 32767) to unsigned words (0-65535)
; and performs endian reversal from big-endian to little-endian format IN-PLACE
; Processing: swap bytes within each 16-bit word, then add 32768

section .text
global _start

_start:
    ; Load buffer pointer: EDX = buffer address. EBX contains byte count.
    mov     edx, [ebp]      ; buffer pointer

    test    ebx, ebx        ; check if byte count is zero
    jz      .done

.loop:
    cmp     ebx, 2          ; check if at least 2 bytes remain
    jb      .done
    
    ; Process one 16-bit word in-place
    mov     ax, word [edx]      ; load 16-bit word from buffer
    xchg    al, ah              ; swap bytes (endian reversal: big->little)
    add     ax, 32768           ; add 32768 (convert signed to unsigned range)
    mov     word [edx], ax      ; store converted word back to buffer
    
    ; Advance pointer and decrement counter
    add     edx, 2              ; move buffer pointer forward 2 bytes
    sub     ebx, 2              ; decrement byte counter by 2
    jmp     .loop               ; continue loop

.done:
    ; Exit (Linux int 0x80 syscall)
    mov     eax, 1              ; sys_exit
    xor     ebx, ebx            ; status 0
    int     0x80
