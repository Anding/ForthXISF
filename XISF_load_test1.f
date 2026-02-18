need forthXISF
need simple-tester
0 value image1
0 value image2

: testA_write-XISFfilepath ( map buf -- )
	>R drop
	s" e:\coding\ForthXISF\testdata\" R@ write-buffer drop
	R@ buffer-punctuate-filepath
	s" test2.xisf" R@ write-buffer drop
	R> drop
;
	ASSIGN testA_write-XISFfilepath TO-DO write-XISFfilepath
	
: make-test2.xisf { | map img -- img }
    640 480 1 allocate-image -> img
    img FITS_MAP @ -> map
    s" 16" map =>" BITPIX"	
    s" 2"	map =>" NAXIS"	
    s" 640" map =>" NAXIS1"
    s" 480" map =>" NAXIS2" 
    640 480 * 0 do
        0x10000 choose img IMAGE_BITMAP i 2* + w!   \ random 16 bit words
    loop   
    img save-XISFimage 
    img
;

    make-test2.xisf -> image1

: test_write-XISFfilepath { map buf -- }
	s" E:\coding\ForthXISF\testdata\" buf write-buffer drop
	buf buffer-punctuate-filepath
	s" clone.xisf" buf write-buffer drop 
;

ASSIGN test_write-XISFfilepath TO-DO write-XISFfilepath

: test.xisf.load-file  ( caddr u -- img)
    xisf.load-file ( img 0 | IOR )
    0= if 
        dup save-XISFimage
    else 
        0
    then
;         
 
cr 
Tstart

T{ s" E:\coding\ForthXISF\testdata\test2.xisf" test.xisf.load-file -> image2
   s" E:\coding\ForthXISF\testdata\clone.xisf" hashF }T 
   s" E:\coding\ForthXISF\testdata\test2.xisf" hashF ==
   
cr
Tend
cr

    