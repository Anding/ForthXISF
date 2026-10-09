\ FITS codec for format-neutral FRAME values.

11520 constant FITS_HEADER_SIZE
FITS_HEADER_SIZE allocate-buffer constant fits.header-buffer
16 2880 * constant FITS_TRANSFER_SIZE
create fits.pixel-buffer FITS_TRANSFER_SIZE allot
\ Header and transfer storage are shared synchronous scratch buffers. The
\ codec is intentionally non-reentrant; the imaging pipeline serializes saves.

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
\ Convert unsigned little-endian camera words to FITS signed big-endian words.
\ BZERO=32768 in the header reconstructs the original unsigned sample values.
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
\ FITS cards retain ordered-map insertion order. Unused fixed-header cards are
\ blank-filled before END so pixel data always starts at FITS_HEADER_SIZE.
    header-buffer reset-buffer
    s" SIMPLE  = T                                                                     " header-buffer write-buffer drop
    frame FRAME_METADATA @ header-buffer FITS.write-map
    header-buffer buffer_space 80 / 1- 0 ?do
        s"                                                                                 " header-buffer write-buffer drop
    loop
    s" END                                                                             " header-buffer write-buffer drop
;

: FITS.write-pixels { frame fileid | source remaining chunk padding -- }
\ Convert bounded chunks directly to the FITS byte order and unsigned offset.
    frame FRAME_BITMAP -> source
    frame frame-size -> remaining
    begin
        remaining
    while
        remaining FITS_TRANSFER_SIZE min -> chunk
        source fits.pixel-buffer chunk convertDataFITS
        fits.pixel-buffer chunk fileid write-file
            abort" Cannot access FITS file"
        source chunk + -> source
        remaining chunk - -> remaining
    repeat
    frame FITS.padded-size frame frame-size - -> padding
    padding if
        fits.pixel-buffer padding erase
        fits.pixel-buffer padding fileid write-file
            abort" Cannot access FITS file"
    then
;

: save-FITSimage-to { frame filepath-buffer | fileid -- }
\ Save a FITS frame to an explicitly prepared pathname.
    frame fits.header-buffer FITS.encode-header
    filepath-buffer create-imageDirectory
    filepath-buffer buffer-to-string w/o
        create-file abort" Cannot create FITS file" -> fileid
    fits.header-buffer BUFFER_ADDR FITS_HEADER_SIZE fileid write-file abort" Cannot access FITS file"
    frame fileid FITS.write-pixels
    fileid close-file abort" Cannot close FITS file"
;

: save-FITSimage { frame filepath-buffer -- }
\ Save through the active science-path policy and remember the resulting path.
    frame s" .fits" filepath-buffer write-science-filepath
    frame filepath-buffer save-FITSimage-to
;
