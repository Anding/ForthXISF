; EBX will contain a number of bytes, n.  n%4=0, that is n is divisible by 4
; [EBP] will contain the address of the destination
; [EBP+4] will contain the address of a source
; EAX, ECX, EDX are scratch registers that do not need to be preserved
; if other registers are used they must be preserved

; This code converts 16-bit unsigned words (0-65535) to signed words (-32768 to 32767)
; and performs endian reversal from little-endian to big-endian format
; Processing: subtract 32768, then swap bytes within each 16-bit word

section .text
global _start

_start:
    ; Load pointers: EDX = source, ECX = destination. EBX contains byte count.
    mov     edx, [ebp+4]    ; source pointer
    mov     ecx, [ebp]      ; destination pointer

    test    ebx, ebx        ; check if byte count is zero
    jz      .done

.loop:
    cmp     ebx, 2          ; check if at least 2 bytes remain
    jb      .done
    
    ; Process one 16-bit word
    mov     ax, word [edx]      ; load 16-bit word
    sub     ax, 32768           ; subtract 32768 (convert unsigned to signed range)
    xchg    al, ah              ; swap bytes (endian reversal: little->big)
    mov     word [ecx], ax      ; store converted word
    
    ; Advance pointers and decrement counter
    add     edx, 2              ; move source pointer forward 2 bytes
    add     ecx, 2              ; move destination pointer forward 2 bytes
    sub     ebx, 2              ; decrement byte counter by 2
    jmp     .loop               ; continue loop

.done:
    ; Exit (Linux int 0x80 syscall)
    mov     eax, 1              ; sys_exit
    xor     ebx, ebx            ; status 0
    int     0x80