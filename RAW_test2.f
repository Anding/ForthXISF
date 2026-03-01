need forthXISF
include "%idir%\RAW.f"

0 value image

s" E:\testdata\images\LUM-E155-F5100-f7843758a3f5.xisf" xisf.load-file drop -> image
    
: test_write-RAWfilepath { map buf -- }
	s" E:\testdata\images\" buf write-buffer drop	
	buf buffer-punctuate-filepath
	s" FILTER" map >string buf write-buffer drop 
	'-' buf echo-buffer drop	
	'E' buf echo-buffer drop	
	s" EXPTIME" map >string buf write-buffer drop
	'-' buf echo-buffer drop		
	'F' buf echo-buffer drop
	s" FOCUSPOS" map >string buf write-buffer drop 
	'-' buf echo-buffer drop
	s" UUID" map >string drop 24 + 12 buf write-buffer drop	
	s" .raw" buf write-buffer drop
	0   buf echo-buffer drop                                   \ zero terminated string
;

    ASSIGN test_write-RAWfilepath TO-DO write-RAWfilepath      
 
    image save-RAWimage
