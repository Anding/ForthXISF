need forthXISF
need simple-tester
0 value image1
0 value image2

: testA_write-FITSfilepath ( map buf -- )
	>R drop
	s" e:\coding\ForthXISF\testdata\" R@ write-buffer drop
	R@ buffer-punctuate-filepath
	s" test2.fits" R@ write-buffer drop
	R> drop
;
	ASSIGN testA_write-FITSfilepath TO-DO write-FITSfilepath

: make-test2.fits { | map img -- img }
    640 480 1 allocate-image -> img
    img FITS_MAP @ -> map
    s" 16" map =>" BITPIX"	
    s" 2"	map =>" NAXIS"	
    s" 640" map =>" NAXIS1"
    s" 480" map =>" NAXIS2" 
    640 480 * 0 do
        0x10000 choose img IMAGE_BITMAP i 2* + w!   \ random 16 bit words
    loop   
    img save-FITSimage 
    img
;

    make-test2.fits -> image1

: testB_write-FITSfilepath { map buf -- }
	s" E:\coding\ForthXISF\testdata\" buf write-buffer drop
	buf buffer-punctuate-filepath
	s" clone.fits" buf write-buffer drop 
;

ASSIGN testB_write-FITSfilepath TO-DO write-FITSfilepath

: test.xisf.load-FITSfile ( caddr u -- img)
    xisf.load-FITSfile ( img 0 | IOR )
    0= if
        dup save-FITSimage  
    else
        0      
    then
;         
 
cr 
Tstart

T{ s" E:\coding\ForthXISF\testdata\test2.fits" test.xisf.load-FITSfile -> image2
   s" E:\coding\ForthXISF\testdata\clone.fits" hashF }T 
   s" E:\coding\ForthXISF\testdata\test2.fits" hashF ==
   
cr
Tend
cr
