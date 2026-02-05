; EBX wlll contain a number of bytes, n.  n%4=0, that is n is divisible by 4
; [EBP} will conbtain the address of the destination
; [EBP+4] will contain the address of a source
; EAX, ECX, EDX are scratch registers that do no need to be prserved
; if other registers are used they must be preserved

; write an x86 assemble language snippet to copy 16-bit words from source to destintion with an Endian reversal.  n bytes in total
; it is permissable to use 32-bit reads and writes, but note the endian reversal must treat each 32-bit word as two separate 16-bit words
; write the code for maxium performance on a latest generation x86 CPU

; write the code in this file, please include comments to explain what you are doing

section .data
align 16
byte_swap_mask:    ; indexes to swap bytes in each 16-bit word: 1,0,3,2,5,4,...
    db 1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14

section .text
global _start

_start:
    ; Load pointers (use EDX = src, ECX = dst). EBX already contains byte count.
    mov     edx, [ebp+4]    ; source pointer
    mov     ecx, [ebp]      ; destination pointer

    test    ebx, ebx
    jz      .done

    ; Load shuffle mask into XMM1 once (requires SSSE3)
    movdqu  xmm1, [byte_swap_mask]

.loop16:
    cmp     ebx, 16
    jb      .check8
    movdqu  xmm0, [edx]     ; load 16 bytes from source
    pshufb  xmm0, xmm1      ; swap bytes within each 16-bit word
    movdqu  [ecx], xmm0     ; store 16 bytes to destination
    add     edx, 16
    add     ecx, 16
    sub     ebx, 16
    jmp     .loop16

.check8:
    cmp     ebx, 8
    jb      .check4
    movq    xmm0, [edx]     ; load low 8 bytes
    pshufb  xmm0, xmm1      ; swap bytes within each 16-bit word (low 8 bytes indices 0..7 used)
    movq    [ecx], xmm0     ; store low 8 bytes
    add     edx, 8
    add     ecx, 8
    sub     ebx, 8

.check4_loop:
    cmp     ebx, 4
    jb      .done
    mov     eax, [edx]      ; load 4 bytes (one 32-bit word = two 16-bit words)
    bswap   eax             ; reverse full dword: b3 b2 b1 b0 -> b0 b1 b2 b3
    ror     eax, 16         ; rotate to produce: b2 b3 b0 b1 (swap bytes inside each 16-bit word)
    mov     [ecx], eax
    add     edx, 4
    add     ecx, 4
    sub     ebx, 4
    jmp     .check4_loop

.done:
    ; Exit (Linux int 0x80 syscall)
    mov     eax, 1          ; sys_exit
    xor     ebx, ebx        ; status 0
    int     0x80