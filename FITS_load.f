\ Functionality to load FITS files

256 buffer: XISF.FITSloadline

: xisf.open-FITSfile ( caddr u -- fileid 0 | IOR )
\ open a FITS file and read the FITS header into buf
\ leave the file pointer at the first byte past the header
    r/o open-file dup if ." Cannot open FITS file" then
;

: XISF.read-FITSline ( caddr u -- caddr1 u1 caddr2 u2 0 | flag )
\ caddr u is a FITS or WCS header line of 80 characters
\ caddr1 u1 is the FITS value with leading and training spaces, and ' ' removed
\ caddr2 u2 is the FITS key with leading and trailing spaces removed
\ flag = 0 for fits key value pair
\ flag = 1 for END
\ flag = 2 for SIMPLE
\ flag = 3 for 9th character not '=', thus ignore comments
    over 8 -white 2dup hash$ case
        [ s" END"     hash$ ] literal of 2drop 2drop 1 endof      
        [ s" SIMPLE"  hash$ ] literal of 2drop 2drop 2 endof
        drop over 8 + c@     \ replace the selector
        '=' of 
            2>R ( caddr u R:caddr2 u2)
            10 /string -white FITSstrToStr
            2R> 0        
        endof
        >R 2drop 2drop 3 R>     \ preserve the selector
     endcase 
;

: xisf.scanFITS-for-fits { img | map -- }
\ scan a FITS header in an image and instantiate the fits map
    img FITS_MAP @ -> map	
    img FITS_BUFFER buffer-to-string ( caddr u) 
    begin
        over 80 XISF.read-FITSline >R
        R@ 0= if map => then
    R> 1 <> while
        80 /string 
        dup 0= if ." Unexpected EOF" 2drop exit then
    repeat
    2drop
;

: XISF.scan-FITSgeometry { fileid | NAXIS1 NAXIS2 depth -- width height depth }
\ scan an FITS header in a file and return the image geometry
\ return 0 0 1 if the geometry is not found
    begin
        XISF.FITSloadline dup 80 fileid ( c-addr c-addr u1 fileid) read-line ( c-addr u2 flag ior) drop
        0= if ." Unexpected EOF" 2drop 0 0 0 exit then
        XISF.read-FITSline >R
        R@ 0= if ( caddr1 u1 caddr2 u2)
            hash$ case 
                [ s" NAXIS"  hash$ ] literal of toInteger 2/ -> depth endof
                [ s" NAXIS1" hash$ ] literal of toInteger -> NAXIS1  endof
                [ s" NAXIS2" hash$ ] literal of toInteger -> NAXIS2  endof
                nip nip
            endcase
        then
     R> 1 = until
     NAXIS1 NAXIS2 depth
;
  
CODE reverseConvertDataFITS ( src n  -- )
    \ Load pointers: EDX = source and destination pointer. EBX contains byte count.
    mov     edx, 0 [ebp]        \ pointer
    test    ebx, ebx            \ check if byte count is zero
    jz      L$2
L$1:
    cmp     ebx, 2              \ check if at least 2 bytes remain
    jb      L$2
    mov     ax, word 0 [edx]    \ load 16-bit word
    xchg    al, ah              \ swap bytes (endian reversal: big->little)
    add     ax, 32768           \ add 32768 (convert signed to unsigned range)
    mov     word 0 [edx], ax    \ store converted word
    add     edx, 2              \ move source pointer forward 2 bytes
    sub     ebx, 2              \ decrement byte counter by 2
    jmp     L$1                 \ continue loop
L$2:
    mov ebx, 04 [ebp]           \ move the 2nd stack item to the cached TOS
    lea ebp, 08 [ebp]           \ move the stack pointer up by 2 cells
    NEXT,    
END-CODE
    
: XISF.read-FITSfile { fileid img -- }
\ read an opened file into an instantiated image structure
\ close the file before returning    
    0 0 fileid reposition-file drop
    img FITS_BUFFER ( buf) FITS_HEADER_SIZE ( buf n ) fileid buffer-read-file 2drop  
    img IMAGE_BITMAP ( addr) img IMAGE_SIZE_WITH_PAD @ ( addr n) fileid read-file 2drop
    img IMAGE_BITMAP ( addr) img IMAGE_SIZE_WITH_PAD @ ( addr n) reverseConvertDataFITS
    fileid close-file drop     
;

: xisf.load-FITSfile { caddr u | fileid img -- img 0 | IOR }
\ allocate an image buffer and load a FITS file 
    caddr u xisf.open-FITSfile if abort" failed to open FITS file" then -> fileid
    fileid xisf.scan-FITSgeometry   ( width height depth) 
    ?dup if 
        allocate-image -> img
        fileid img xisf.read-FITSfile
        fileid close-file drop
        img xisf.scanFITS-for-fits
        img 0
    else
        2drop
        fileid close-file drop
        -1
    then
;
