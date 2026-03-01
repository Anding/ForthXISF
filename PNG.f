\ save a 16-bit greyscale image as an 8-bit PNG file

DEFER write-PNGfilepath ( map buf --)

: default_write-PNGfilepath { map buf -- }
	s" e:\images\snapshot\" buf write-buffer drop	
	buf buffer-punctuate-filepath
	s" image.png" buf write-buffer drop
	0 buf echo-buffer drop                                   \ zero terminated string
;

    ASSIGN default_write-PNGfilepath TO-DO write-PNGfilepath
    
: initialize-PNGfilepath ( img --)
	>R
	R@ FITS_MAP @ ( map)
	R> PNG_FILEPATH_BUFFER
	FILEPATH_SIZE over ( map buf FILEPATH_SIZE buf) declare-buffer
	( map buf) write-PNGfilepath
;

: save-PNGimage ( img -- )
	>R
	R@ initialize-PNGfilepath
	R@ PNG_FILEPATH_BUFFER create-imageDirectory
    R@ IMAGE_BITMAP
    R@ IMAGE_WIDTH @
    R@ IMAGE_HEIGHT @
    R@ PNG_FILEPATH_BUFFER buffer-to-string drop
    ( bitmap width height caddr) SaveBitmapAsPNG if ." Error writing PNG file" then
    R> drop
;