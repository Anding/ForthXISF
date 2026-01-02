\ prepare a filepath with filename for an XISF file

: default_write-XISFfilepath_buffer { map buf -- }									\ VFX locals
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
	s" .xisf" buf write-buffer drop
;

	ASSIGN default_write-XISFfilepath_buffer TO-DO write-XISFfilepath_buffer		\ VFX state-smart alternatives to IS

: default_write-FITSfilepath_buffer { map buf -- }									\ VFX locals
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

	ASSIGN default_write-FITSfilepath_buffer TO-DO write-FITSfilepath_buffer
		