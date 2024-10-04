\ prepare a filepath with filename for an XISF file
\ requires buffers.f, ForthBase.f, FiniteFractions.f, forth-map.fs

DEFER write-filepath_buffer ( map buf --)
\ map is a completed FITSKEY map that will interrogated to create the filename
\ buf points to IMAGE_DESCRIPTOR..FILEPATH_BUFFER 

: initialize-XISFfilepath ( img --)
\ prepare the filepath with filename for the XISF file
\ called by save-image
	>R
	R@ FITS_MAP @
	R> FILEPATH_BUFFER
	256 over ( size buf) declare-buffer
	( map buf) write-filepath_buffer
;

: default_write-filepath_buffer { map buf -- }									\ VFX locals
\ format: e:\images\2024-10-04\2024-10-05T00:10:30_1aa02f27
	\ filepath
	s" e:\images\" buf write-buffer drop
	s" LOCALDAY" map >string buf write-buffer drop 
	'\' buf echo-buffer drop
	\ filename
	s" LOCAL-DT" map >string drop 19 buf write-buffer drop 
	'|' buf echo-buffer drop
	s" UUID" map >string drop 8 buf write-buffer drop
;

	ASSIGN default_write-filepath_buffer TO-DO write-filepath_buffer		\ VFX state-smart alternatives to IS

	