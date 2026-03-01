need forthXISF
include "%idir%\PNG.f"

0 value image
	
: make-random.xisf { | map img -- img }
    640 480 1 allocate-image -> img
    img FITS_MAP @ -> map
    s" 16" map =>" BITPIX"	
    s" 2"	map =>" NAXIS"	
    s" 640" map =>" NAXIS1"
    s" 480" map =>" NAXIS2" 
    640 480 * 0 do
        0x10000 choose img IMAGE_BITMAP i 2* + w!   \ random 16 bit words
    loop   
    img
;

    make-random.xisf -> image
    
: test_write-PNGfilepath { map buf -- }
	s" E:\coding\ForthXISF\testdata\" buf write-buffer drop	
	buf buffer-punctuate-filepath
	s" random-image.png" buf write-buffer drop
	0 buf echo-buffer drop                                   \ zero terminated string
;

    ASSIGN test_write-PNGfilepath TO-DO write-PNGfilepath      
 
    image save-PNGimage
