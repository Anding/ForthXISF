\ FITS codec for format-neutral FRAME values.

11520 constant FITS_HEADER_SIZE
FITS_HEADER_SIZE allocate-buffer constant fits.header-buffer

: FITS.map-iterate ( buf c-addr u map -- buf )
    >R rot R> swap >R
    -rot dup 8 > if 2drop drop R> exit then
    2dup R@ write-buffer drop
    dup 8 swap ?do bl j echo-buffer drop loop
    s" = " R@ write-buffer drop
    rot >string 68 min StrToFITSStr 2dup R@ write-buffer drop
    dup 70 swap ?do bl j echo-buffer drop loop
    2drop R>
;

: FITS.write-map ( map buf -- )
    ['] FITS.map-iterate rot simple-iterate-map drop
;

: FITS.padded-size ( frame -- size )
    frame-size 2879 + 2880 / 2880 *
;

CODE convertDataFITS ( src dst n -- )
    mov     edx, 4 [ebp]
    mov     ecx, 0 [ebp]
    test    ebx, ebx
    jz      L$2
L$1:
    cmp     ebx, 2
    jb      L$2
    movzx   ax, word 0 [edx]
    sub     ax, 32768
    xchg    al, ah
    mov     word 0 [ecx], ax
    add     edx, 2
    add     ecx, 2
    sub     ebx, 2
    jmp     L$1
L$2:
    mov ebx, 08 [ebp]
    lea ebp, 12 [ebp]
    NEXT,
END-CODE

: FITS.encode-header { frame header-buffer -- }
    header-buffer reset-buffer
    s" SIMPLE  = T                                                                     " header-buffer write-buffer drop
    frame FRAME_METADATA @ header-buffer FITS.write-map
    header-buffer buffer_space 80 / 1- 0 ?do
        s"                                                                                 " header-buffer write-buffer drop
    loop
    s" END                                                                             " header-buffer write-buffer drop
;

: save-FITSimage-to { frame filepath-buffer | fileid pixel-buffer padded-size -- }
    frame fits.header-buffer FITS.encode-header
    filepath-buffer create-imageDirectory
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create FITS file" -> fileid
    fits.header-buffer BUFFER_ADDR FITS_HEADER_SIZE fileid write-file abort" Cannot access FITS file"
    frame FITS.padded-size -> padded-size
    padded-size allocate abort" unable to allocate FITS buffer" -> pixel-buffer
    pixel-buffer padded-size erase
    frame FRAME_BITMAP pixel-buffer frame frame-size convertDataFITS
    pixel-buffer padded-size fileid write-file abort" Cannot access FITS file"
    pixel-buffer free drop
    fileid close-file abort" Cannot close FITS file"
;
