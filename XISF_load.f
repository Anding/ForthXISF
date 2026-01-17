\ Functionality to load XISF files
\ limited to XISF files created in ForthXISF!

: xisf.open-file ( caddr u -- fileid buf 0 | IOR )
\ open an XISF file and read the XISF header into buf
\ leave the file pointer at the first byte past the header
    r/o open-file ?dup if ." Cannot open XISF file" exit then
    XISF_HEADER_SIZE allocate-buffer    ( fileid buf)
    2dup XISF_HEADER_SIZE rot
    ( fileid buf buf n fileid) buffer-read-file ( fileid buf n2 IOR)
    ?dup if nip nip nip ." Cannot read XISF file" exit then
    XISF_HEADER_SIZE = 0= if nip nip ." Cannot read full XISF buffer" exit then
    0
;

: xisf.scan-for-geometry ( buf -- width height depth )
\ scan an xisf header in a buffer and return the XISF geometry
\ return 0 0 0 if the geometry tag is not found
\ close the buffer before return
    >R R@ buffer-reset-search
    ( geometry="~"*") s\" geometry=\"~\"*\"" 
    R@ buffer-match ( c-addrM uM -1 | 0)
    R> free-buffer
    0= if 0 0 0 exit then
    10 /string 1-       \ remove geometry=" and the closing "
    >number~~~
;

: xisf.read-file { fileid img -- }
\ read an opened file into an instantiated image structure
\ close the file before returning
    0 0 fileid reposition-file drop
    img XISF_BUFFER	( buf) XISF_HEADER_SIZE ( buf n ) fileid buffer-read-file 2drop
    img IMAGE_BITMAP ( addr) img image_size ( addr n ) fileid read-file 2drop
    fileid close-file drop
;


: xisf.scan-for-fits ( img --) 
\ scan an xisf header in an image and instantiate the fits map
    >R
    map ( forth-map) R@ FITS_map !          \ move this to allocate-image
    R@ XISF_BUFFER buffer-reset-search    
    begin
        s" <FITSKeyword" R@ XISF_BUFFER buffer-match
    while
        2drop
        s\" name=\"~\"*\"" R@ XISF_BUFFER buffer-match 
        if
            6 /string 1-                    ( caddr n)   
            s\" value=\"~\"*\"" R@ XISF_BUFFER buffer-match   
            if 
                7 /string 1-                ( caddr n caddr n)     
                2swap R@ FITS_map @
                ( caddrV nV caddrK nK map) =>   
            then      
         then         
    repeat
    R> drop
;

: xisf.load-file ( caddr u | fileid buf img  -- img 0 | IOR )
\ allocate an image buffer and load an XISF file 
    xisf.open-file if exit then     ( fileid buf)
    xisf.scan-for-geometry          ( fileid width height depth) 
    ?dup if 
        allocate-image              ( fileid img)
        dup -rot                    ( img fileid img)
        xisf.read-file              ( img)
        dup xisf.scan-for-fits      ( img) 
        0
    else
        2drop
        close-file drop
        -1
    then
;
       
    





    
