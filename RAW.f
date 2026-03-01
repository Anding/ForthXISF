\ save a 16-bit greyscale image as a raw 16 bit binary file

DEFER write-RAWfilepath ( map buf --)

: default_write-RAWfilepath { map buf -- }
	s" e:\images\snapshot\" buf write-buffer drop	
	buf buffer-punctuate-filepath
	s" image.raw" buf write-buffer drop
	0 buf echo-buffer drop                                   \ zero terminated string
;

    ASSIGN default_write-RAWfilepath TO-DO write-RAWfilepath
    
: initialize-RAWfilepath ( img --)
	>R
	R@ FITS_MAP @ ( map)
	R> RAW_FILEPATH_BUFFER
	FILEPATH_SIZE over ( map buf FILEPATH_SIZE buf) declare-buffer
	( map buf) write-RAWfilepath
;

: save-RAWimage ( img -- )
	>R
	R@ initialize-RAWfilepath
	R@ RAW_FILEPATH_BUFFER create-imageDirectory
    R@ IMAGE_BITMAP
    R@ IMAGE_WIDTH @
    R@ IMAGE_HEIGHT @
    R@ RAW_FILEPATH_BUFFER buffer-to-string drop
    ( bitmap width height caddr) SaveBitmapAsBinary if ." Error writing RAW file" then
    R> drop
;