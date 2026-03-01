\ save a 16-bit greyscale image as an 8-bit PNG file

LIBRARY: XISF.dll
    
Extern: void "C" SaveBitmapAsPNG( int * bitmap, int width, int height, char * filename ) ;

DEFER write-PNGfilepath ( map buf --)

: default_write-PNGfilepath { map buf -- }
	s" e:\images\snapshot\" buf write-buffer drop	
	buf buffer-punctuate-filepath
	s" image.png" buf write-buffer drop
	0 buf echo-buffer drop                                   \ zero terminated string
;

    ASSIGN default_write-PNGfilepath TO-DO write-PNGfilepath
    
: initialize-PNGfilepath ( img --)
\ prepare the filepath with filename for the XISF file
\ called by save-image
	>R
	R@ FITS_MAP @ ( map)
	R> PNG_FILEPATH_BUFFER
	FILEPATH_SIZE over ( map buf FILEPATH_SIZE buf) declare-buffer
	( map buf) write-PNGfilepath
;

: save-PNGimage ( img -- )
\ save the image to an FITS file, the filename is created according to write-FITSfilepath_buffer
\ save-FITSimage reverses the image bytes in memory to big-endian format so must be called AFTER save-XISF image
	>R
	R@ initialize-PNGfilepath
	R@ PNG_FILEPATH_BUFFER create-imageDirectory
    R@ IMAGE_BITMAP
    R@ IMAGE_WIDTH @
    R@ IMAGE_HEIGHT @
    R@ PNG_FILEPATH_BUFFER buffer-to-string drop
    ( bitmap width height caddr) SaveBitmapAsPNG
    R> drop
;