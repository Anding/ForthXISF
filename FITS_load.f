\ Functionality to load FITS files

256 buffer: XISF.FITSloadline
0 value XISF.FITSloadNAXIS1
0 value XISF.FITSloadNAXIS2

: xisf.open-FITSfile ( caddr u -- fileid 0 | IOR )
\ open a FITS file and read the FITS header into buf
\ leave the file pointer at the first byte past the header
    r/o open-file dup if ." Cannot open FITS file" then
;

: XISF.read-FITSline ( caddr u -- caddr1 u1 caddr2 u2 0 | IOR )
\ caddr u is a FITS or WCS header line of 80 characters
\ caddr1 u1 is the FITS value with leading and training spaces, and ' ' removed
\ caddr2 u2 is the FITS key with leading and trailing spaces removed
\ IOR = 1 for END
    over 8 + c@ '=' = if                \ basic validation that the 9th character is '=', and thus ignore comments
        2dup drop 8 -white 2>R ( caddr u R:caddr2 u2)
        10 /string -white FITSstrToStr
        2R> 0
    else
        -white s" END" str= if 1 else -1 then
   then
;

: XISF.scan-FITSgeometry ( fileid -- width height depth )
\ scan an FITS header and return the image geometry
\ return 0 0 0 if the geometry is not found
    >R 
    begin
        XISF.FITSloadline dup 256 R@ ( c-addr c-addr u1 fileid) read-line ( c-addr u2 flag ior) drop
        0= if ." Unexpected EOF" 2drop 0 0 0 exit then
        XISF.read-FITSline 
     dup 1 <> while
        0= if 
            hash$ case 
                0 ( " NAXIS1") of toInteger -> XISF.FITSloadNAXIS1  endof
                0 ( " NAXIS2") of toInteger -> XISF.FITSloadNAXIS2  endof
                nip nip
            endcase
        then
     repeat
     2drop           
     XISF.FITSloadNAXIS1 XISF.FITSloadNAXIS2 1
;
    
: XISF.read-FITSfile { fileid img -- }
\ read an opened file into an instantiated image structure
\ close the file before returning    
;

: xisf.scanFITS-for-fits ( img --) 
\ scan a FITS header in an image and instantiate the fits map
;

: xisf.load-FISTfile ( caddr u | fileid buf img  -- img 0 | IOR )
\ allocate an image buffer and load a FITS file 
    xisf.open-FITSfile if exit then     ( fileid buf)
    xisf.scan-FITSgeometry          ( fileid width height depth) 
    ?dup if 
        allocate-image              ( fileid img)
        dup -rot                    ( img fileid img)
        xisf.read-FITSfile              ( img)
        dup xisf.scanFITS-for-fits      ( img) 
        dup initialize-image        ( img)
        0
    else
        2drop
        close-file drop
        -1
    then
;


























: XISF.load-WCS ( caddr u | file