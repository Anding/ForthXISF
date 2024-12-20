\ prepare a filepath with filename for an XISF file

: default_write-filepath_buffer { map buf -- }									\ VFX locals
\ map is a completed FITSKEY map that will interrogated to create the filename
\ buf may point to IMAGE_DESCRIPTOR..FILEPATH_BUFFER to complete the XISF structure
\ 
\ format: e:\images\2024-10-04\2024-10-05T00:10:30_1aa02f27
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
	s" UUID" map >string drop 24 + 12 buf write-buffer drop
	s" .xisf" buf write-buffer drop
;

	ASSIGN default_write-filepath_buffer TO-DO write-filepath_buffer		\ VFX state-smart alternatives to IS

	