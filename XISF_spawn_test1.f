need forthXISF

need simple-tester
0 value image1
0 value image2
	
: make-test.xisf { | map img -- img }
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

    make-test.xisf -> image1      
    image1 XISF.spawn -> image2
    
cr 
Tstart
T{ image1 IMAGE_SIZE_BYTES @ }T image2 IMAGE_SIZE_BYTES @ ==
T{ image1 FITS_MAP @ }T image2 FITS_MAP @ ==
cr
Tend
cr

    