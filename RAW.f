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

: SaveBitmapAsBinary { bitmap width height caddr | fileid bitdepth t -- IOR }
    caddr zcount delete-file drop
    caddr zcount w/o create-file if -1 exit then -> fileid
    s" AIMG" fileid write-file drop
    ADDR width 4 fileid write-file drop
    ADDR height 4 fileid write-file drop
    16 -> bitdepth
    ADDR bitdepth 4 fileid write-file drop
    0 -> t
    ADDR t 4 fileid write-file drop
    bitmap width height * 2* fileid write-file drop
    fileid close-file ( IOR)
;

: save-RAWimage { img -- }
	img initialize-RAWfilepath
	img RAW_FILEPATH_BUFFER create-imageDirectory
    img IMAGE_BITMAP
    img IMAGE_WIDTH @
    img IMAGE_HEIGHT @
    img RAW_FILEPATH_BUFFER buffer-to-string drop
    ( bitmap width height caddr) SaveBitmapAsBinary abort" Error writing RAW file"
;