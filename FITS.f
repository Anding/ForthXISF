\ additional functionality for saving FITS files

: XISF.mapIterFITS ( buf c-addr u map -- buf)
\ forth-map iterator
\ c-addr u is each key as a string
\ output format: FOCUSPOS= 2000  ...padded to 80 charaters
	>R rot R> swap >R									( c-addr u map R:buf)
	\ write the FITS key, skipping any malformed keys with >8 characters
	-rot dup 8 > if 2drop drop R> ( buf) exit then      ( map c-addr u R:buf)
	2dup R@ write-buffer drop				            ( map c-addr u R:buf)
	\ pad with spaces to 8 characters
	dup 8 swap ?do bl j ( do loop hides R@) echo-buffer drop loop
	\ write = 
	s" = " R@ write-buffer drop                         ( map c-addr u R:buf)
	\ obtain the value from the key and write it, limiting the value to 68 characters ( 70 with ' ')
	rot >string 68 min StrToFITSStr 					( caddr u R:buf)
	2dup R@ write-buffer drop
	\ pad with spaces to 80 characters (70 after the keywords and mandtaory characters)
	\ KEYWORD = 
	\ 1234567890
	dup 70 swap ?do bl j ( do loop hides R@) echo-buffer drop loop
	2drop
	R>                                                  ( buf)
;

: XISF.write-map-FITS ( map buf --)
\ write out the FITS map as a series of XML structures
\ <FITSKeyword name="FOCUSPOS" value="2000" />
	['] XISF.mapIterFITS rot ( buf xt map) simple-iterate-map
	drop
;

CODE convertDataFITS ( src dst n  -- )
    \ Load pointers: EDX = source, ECX = destination. EBX contains byte count.
    mov     edx, 4 [ebp]        \ source pointer
    mov     ecx, 0 [ebp]        \ destination pointer    
    test    ebx, ebx            \ check if byte count is zero
    jz      L$2
L$1:
    cmp     ebx, 2              \ check if at least 2 bytes remain
    jb      L$2
    movzx   eax, word 0 [edx]   \ load 16-bit word (zero-extended to 32 bits)
    sub     ax, 32768           \ subtract 32768 (convert unsigned to signed range)
    xchg    al, ah              \ swap bytes (endian reversal: little->big)
    mov     word 0 [ecx], ax    \ store converted word
    add     edx, 2              \ move source pointer forward 2 bytes
    add     ecx, 2              \ move destination pointer forward 2 bytes
    sub     ebx, 2              \ decrement byte counter by 2
    jmp     L$1                 \ continue loop
L$2:
    mov ebx, 08 [ebp]           \ move the 3rd stack item to the cached TOS
    lea ebp, 12 [ebp]           \ move the stack pointer up by 3 cells
    NEXT,    
END-CODE

DEFER write-FITSfilepath ( map buf --)

: default_write-FITSfilepath { map buf -- }									\ VFX locals
\ map is a completed FITSKEY map that will interrogated to create the filename
\ buf may point to IMAGE_DESCRIPTOR..FILEPATH_BUFFER to complete the XISF structure
\ 
	\ directory
	s" e:\images\" buf write-buffer drop
	s" NIGHTOF" map >string buf write-buffer drop 
	'\' buf echo-buffer drop
	s" IMAGETYP" map >string buf write-buffer drop 
	'\' buf echo-buffer drop
	
	buf buffer-punctuate-filepath
	
	\ filename
	s" FILTER" map >string buf write-buffer drop 
	'-' buf echo-buffer drop	
	
	'E' buf echo-buffer drop	
	s" EXPTIME" map >string buf write-buffer drop
	'-' buf echo-buffer drop		
	
	'F' buf echo-buffer drop
	s" FOCUSPOS" map >string buf write-buffer drop 
	'-' buf echo-buffer drop
	
	s" UUID" map >string drop 24 + 12 buf write-buffer drop
	s" .fits" buf write-buffer drop
;

    ASSIGN default_write-FITSfilepath TO-DO write-FITSfilepath


	
: initialize-FITSfilepath ( img --)
\ prepare the filepath with filename for the XISF file
\ called by save-image
	>R
	R@ FITS_MAP @ ( map)
	R> FITS_FILEPATH_BUFFER
	FILEPATH_SIZE over ( map buf FILEPATH_SIZE buf) declare-buffer
	( map buf) write-FITSfilepath
;

: initialize-FITSimage { img | buf -- }
\ prepare the image in FITS format
\ called by save-FITSimage
	img FITS_BUFFER -> buf
	buf reset-buffer
	\ next line becuase T cannot be 'T'
	s" SIMPLE  = T                                                                     " buf write-buffer drop
	\ write the FITS map	
	img FITS_MAP @ buf XISF.write-map-FITS
	\ write the END keyword
	s" END" buf write-buffer drop
	buf buffer_used 2880 /mod drop ( rem)
	?dup if 
		\ pad the buffer with spaces to a multiple of 2880 bytes
		2880 swap ?do bl buf echo-buffer drop loop
	then 
;

: save-FITSimage { img | fileid FITSbuffer -- }		\ VFX locals
\ save the image to an FITS file, the filename is created according to write-FITSfilepath_buffer
\ save-FITSimage reverses the image bytes in memory to big-endian format so must be called AFTER save-XISF image
	img initialize-FITSimage
	img initialize-FITSfilepath
	img FITS_FILEPATH_BUFFER create-imageDirectory
	img FITS_FILEPATH_BUFFER buffer-to-string w/o 
		create-file abort" Cannot create FITS file" -> fileid
	img FITS_BUFFER fileid buffer-to-file
	img IMAGE_SIZE_WITH_PAD @ allocate abort" unable to allocate image" -> FITSbuffer
	img IMAGE_BITMAP FITSbuffer img IMAGE_SIZE_WITH_PAD @ convertDataFITS 
	FITSbuffer img IMAGE_SIZE_WITH_PAD @ ( addr u ) fileid write-file abort" Cannot access FITS file"	
	FITSbuffer free drop
	fileid close-file abort" Cannot close FITS file"
;