\ Forth language tools for creating PixInsight XISF image format
\ requires buffers.f, ForthBase.f, FiniteFractions.f
\ https://pixinsight.com/doc/docs/XISF-1.0-spec/XISF-1.0-spec.html

NEED ForthBase
NEED FiniteFractions
NEED buffers
NEED forth-map
NEED ForthXML

256   constant FILEPATH_SIZE
8192  constant XISF_HEADER_SIZE
11520 constant FITS_HEADER_SIZE	\ enough for 144 80-column cards, being 4 x 2880

\ descriptor data structure for an image
BEGIN-STRUCTURE IMAGE_DESCRIPTOR
                4   +FIELD IMAGE_WIDTH				\ width in pixels
                4   +FIELD IMAGE_HEIGHT				\ height in pixels
                4   +FIELD IMAGE_DEPTH				\ depth in bitplane
                4   +FIELD IMAGE_SIZE_BYTES			\ image size in bytes
                4   +FIELD IMAGE_SIZE_WITH_PAD		\ image size after padding to 2880 boundary for FITS
                4   +FIELD FITS_MAP					\ pointer to the key-value FITS map
BUFFER_DESCRIPTOR   +FIELD XISF_FILEPATH_BUFFER	\ descriptor to the XISF filepath with filename buffer
FILEPATH_SIZE       +FIELD XISF_FILEPATH				\ XISF filepath with filename, as a buffer
BUFFER_DESCRIPTOR   +FIELD FITS_FILEPATH_BUFFER	\ descriptor to the XISF filepath with filename buffer
FILEPATH_SIZE       +FIELD FITS_FILEPATH				\ XISF filepath with filename, as a buffer				 			 
BUFFER_DESCRIPTOR   +FIELD FITS_BUFFER				\ descriptor to the FITS header buffer
FITS_HEADER_SIZE    +FIELD FITS_HEADER				\ FITS header buffer immediately follows the descriptor
BUFFER_DESCRIPTOR   +FIELD XISF_BUFFER				\ descriptor to the XISF header buffer
XISF_HEADER_SIZE    +FIELD XISF_HEADER				\ XISF header buffer immediately follows the descriptor
				0 	+FIELD IMAGE_BITMAP				\ image bitmap immediately follows the XISF header
END-STRUCTURE

: allocate-image  ( width height depth -- img )
\ allocate memory and establish a new image, as represented by a descriptor
	3dup
	2* * * ( w h d image_bytes)
	dup dup 2880 /mod drop ( rem) 2880 swap - +	( w h d image_bytes padded_image_bytes)
	dup IMAGE_DESCRIPTOR +		   					( w h d image_bytes padded_image_bytes total_bytes)
	allocate abort" unable to allocate image" 
	>R															( w h d image_bytes padded_image_bytes R: img)
	R@ IMAGE_SIZE_WITH_PAD !
	R@ IMAGE_SIZE_BYTES !
	R@ IMAGE_DEPTH !
	R@ IMAGE_HEIGHT !
	R@ IMAGE_WIDTH !	
	XISF_HEADER_SIZE R@ XISF_BUFFER ( size buf) declare-buffer
	FITS_HEADER_SIZE R@ FITS_BUFFER ( size buf) declare-buffer
	R@ IMAGE_BITMAP R@ IMAGE_SIZE_WITH_PAD @ erase		\ zero the image buffer including the pad
	map ( forth-map) R@ FITS_map !
	R>
;

: free-image ( img --)
\ release the memory allocated to an image
	free drop
;

: image_size ( img -- size_in_bytes)
	IMAGE_SIZE_BYTES @
;

: initialize-image { img | map x y -- }
   img FITS_MAP @ -> map
   s" NAXIS1" map >integer -> x
   s" NAXIS2" map >integer -> y
   x img IMAGE_WIDTH !
   y img IMAGE_HEIGHT !
   x y * 2 * dup img IMAGE_SIZE_BYTES !
   dup 2880 /mod drop ( rem) 2880 swap - +	img IMAGE_SIZE_WITH_PAD !
;

: IsFITSnumchar? ( c -- flag)
\ check if a character is a valid FITS key numeric 
   >R 0
   R@ '+' = OR
   R@ '-' = OR
   R@ '.' = OR
   R@ 'E' = OR
   R@ 'e' = OR
   R> '0' '9' within? OR
; 

s" " $value FITSstringBuf
   
: StrToFITSStr ( caddr u -- caddr u)
\ convert a string to comply with FITS key requirements
\ by enclosing any non-numeric in '
 2dup -1 -rot ( caddr u flag caddr u) over + swap do i c@ IsFITSnumchar? and dup 0= if leave then loop 
 0= if  \ the file contained a non FITSnumeric character, so copy it over with enclosing ' ' 
    s" '" $-> FITSstringBuf $+> FITSstringBuf s" '" $+> FITSstringBuf FITSstringBuf  
 then
;

: FITSstrToStr ( caddr u -- caddr u)
\ convert a key in FITS string format
\ by eliminating any enclosing '
    over c@ ''' = if 2 - swap 1 + swap then
; 

: XISF.mapIterXISF ( buf c-addr u map -- buf)
\ forth-map iterator
\ c-addr u is each key as a string
\ output format: <FITSKeyword name="FOCUSPOS" value="2000" />
	>R rot R> swap >R									( c-addr u map R:buf)
	s" FITSKeyword" R@ xml.<tag	
	-rot 2dup s" name" 2swap R@ xml.keyval 	( c-addr u map R:buf)
	rot >string StrToFITSStr				      	    ( c-addr u R:buf)		
	s" value" 2swap R@ xml.keyval					    ( R:buf)
	R@ xml./>
	R>
;

: XISF.write-map-XISF ( map buf --)
\ write out the FITS map as a series of XML structures within an XISF file
\ <FITSKeyword name="FOCUSPOS" value="2000" />
	['] XISF.mapIterXISF rot ( buf xt map) simple-iterate-map
	drop
;

: create-imageDirectory ( FILEPATH_BUFFER --)
\ if the image directory does not exist on disk, create it
	>R
	R@ ( buf) buffer-drive-to-string	R> buffer-dir-to-string makeDirLevels abort" cannot create image directory"
;
	
DEFER write-XISFfilepath ( map buf --)
\ map is a completed FITSKEY map that will interrogated to create the filename
\ buf points to IMAGE_DESCRIPTOR..FILEPATH_BUFFER 

: default_write-XISFfilepath { map buf -- }									\ VFX locals
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

	ASSIGN default_write-XISFfilepath TO-DO write-XISFfilepath		\ VFX state-smart alternatives to IS

: initialize-XISFfilepath ( img --)
\ prepare the filepath with filename for the XISF file
\ called by save-image
	>R
	R@ FITS_MAP @ ( map)
	R> XISF_FILEPATH_BUFFER
	FILEPATH_SIZE over ( map buf FILEPATH_SIZE buf) declare-buffer
	( map buf) write-XISFfilepath
;

: initialize-XISFimage ( img --)
\ prepare the image in XISF format
\ called by save-XISFimage
	dup >R XISF_BUFFER >R	( R: img buf)
	R@ reset-buffer
	s" XISF010000000000" R@ write-buffer abort" buffer full"	\ XISF signature \ XISF header length \ XISF reserved
	R@ xml.<??>
	s" xisf" R@ xml.<tag
		s" version" s" 1.0" R@ xml.keyval
	R@ xml.>
	s" Image" R@ xml.<tag
		s" geometry"
			2R@ drop IMAGE_WIDTH @ 2R@ drop IMAGE_HEIGHT @ 2R@ drop IMAGE_DEPTH @
			~~~$	( finite fractions utility) R@ xml.keyval
		s" sampleFormat"  s" SMPLFRMT" 2R@ drop FITS_MAP @ >string R@ xml.keyval
		s" colorSpace" s" COLORSPC" 2R@ drop FITS_MAP @ >string R@ xml.keyval		
		s" offset"  s" OFFSET" 2R@ drop FITS_MAP @ >string R@ xml.keyval
		s" imageType" s" IMAGETYP" 2R@ drop FITS_MAP @ >string R@ xml.keyval
		s" uuid" s" UUID" 2R@ drop FITS_MAP @ >string R@ xml.keyval
		s" location" s" attachment:" R@ xml.keyval
			XISF_HEADER_SIZE 0 <# #s #> R@ xml.append s" :" R@ xml.append
			2R@ drop image_size 0 <# #s #> R@ xml.append
	R@ xml.>
	2R@ drop FITS_MAP @ dup IF R@ ( map buf --) XISF.write-map-XISF ELSE drop THEN
	s" Image" R@ xml.</tag>
	s" xisf" R@ xml.</tag>
	R@ buffer_used R@ BUFFER_DESCRIPTOR + 8 + !	\ store the XISF header length
	R> R> drop drop
;

: save-XISFimage { img | fileid -- }		\ VFX locals
\ save the image to an XISF file, the filename is created according to write-XISFfilepath_buffer 
	img initialize-XISFimage
	img initialize-XISFfilepath
	img XISF_FILEPATH_BUFFER create-imageDirectory
	img XISF_FILEPATH_BUFFER buffer-to-string w/o 
		create-file abort" Cannot create XISF file" -> fileid
	img XISF_HEADER							( addr)
	img image_size XISF_HEADER_SIZE +	( addr file_size)
		fileid write-file abort" Cannot access XISF file"	
	fileid close-file abort" Cannot close XISF file"
;



