\ Forth language tools for creating PixInsight XISF image format
\ requires buffers.f, ForthBase.f, FiniteFractions.f
\ https://pixinsight.com/doc/docs/XISF-1.0-spec/XISF-1.0-spec.html

NEED FothBase
NEED FiniteFractions
NEED buffers
NEED forth-map
NEED ForthXML

8192 constant XISF_HEADER_SIZE

\ descriptor data structure for an image
BEGIN-STRUCTURE IMAGE_DESCRIPTOR
					4 	+FIELD IMAGE_WIDTH				\ width in pixels
					4 	+FIELD IMAGE_HEIGHT				\ height in pixels
					4 	+FIELD IMAGE_DEPTH				\ depth in bitplanes
					4 	+FIELD FITS_MAP					\ pointer to the key-value FITS map
					4	+FIELD XISF_MAP					\ pointer to the key-value XISF map	
BUFFER_DESCRIPTOR +FIELD FILEPATH_BUFFER			\ descriptor to the filepath with filename buffer
				 256	+FIELD FILEPATH					\ filepath with filename, as a buffer
BUFFER_DESCRIPTOR +FIELD XISF_BUFFER				\ descriptor to the XISF header buffer
XISF_HEADER_SIZE	+FIELD XISF_HEADER				\ XISF header buffer immediately follows the descriptor
					0 	+FIELD IMAGE_BITMAP				\ image bitmap immediately follows the XISF header
END-STRUCTURE

: allocate-image  ( width height depth -- img )
\ allocate memory and establish a new image, as represented by a descriptor
	3dup
	2* * * IMAGE_DESCRIPTOR +
	allocate abort" unable to allocate image"
	>R					( w h d R: img)
	R@ IMAGE_DEPTH !
	R@ IMAGE_HEIGHT !
	R@ IMAGE_WIDTH !
	XISF_HEADER_SIZE R@ XISF_BUFFER ( size buf) declare-buffer
	R>
;

: free-image ( img --)
\ release the memory allocated to an image
	free drop
;

: image_size ( img -- size_in_bytes)
	>R
	R@ IMAGE_WIDTH @
	R@ IMAGE_HEIGHT @
	R> IMAGE_DEPTH @
	2* * * 
;

: XISF.FITSmapIter ( buf c-addr u map -- buf)
\ forth-map iterator
\ output format: <FITSKeyword name="FOCUSPOS" value="2000" />
	>R rot R> swap >R									( c-addr u map R:buf)
	s" FITSKeyword" R@ xml.<tag	
	-rot 2dup s" name" 2swap R@ xml.keyval 	( c-addr u map R:buf)
	rot >string				      					( c-addr u R:buf)		
	s" value" 2swap R@ xml.keyval					( R:buf)
	R@ xml./>
	R>
;

: XISF.write-FITSmap ( map buf --)
\ write out the FITS map as a series of XML structures
\ <FITSKeyword name="FOCUSPOS" value="2000" />
	['] XISF.FITSmapIter rot ( buf xt map) simple-iterate-map
	drop
;

: XISF.XISFmapIter { buf c-addr u map -- buf } 	\ VFX locals
\ forth-map iterator
\ outputformat: sampleFormat="UInt16"
	c-addr u 2dup map >string buf xml.keyval 		( c-addr u map R:buf)
	buf
;

: XISF.write-XISFmap ( map buf --)
\ write out the XISF map into the image XML tag
\ sampleFormat="UInt16"
	['] XISF.XISFmapIter rot ( buf xt map) simple-iterate-map
	drop
;

: initialize-XISFimage ( img --)
\ prepare the image in XISF format
\ called by image-to-file
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
 			2R@ drop XISF_MAP @ dup IF R@ ( map buf --) XISF.write-XISFmap ELSE drop THEN
			s" location" s" attachment:" R@ xml.keyval
			XISF_HEADER_SIZE 0 <# #s #> R@ xml.append s" :" R@ xml.append
			2R@ drop image_size 0 <# #s #> R@ xml.append
	R@ xml.>
	2R@ drop FITS_MAP @ dup IF R@ ( map buf --) XISF.write-FITSmap ELSE drop THEN
	s" Image" R@ xml.</tag>
	s" xisf" R@ xml.</tag>
	R@ buffer_used R@ BUFFER_DESCRIPTOR + 8 + !	\ store the XISF header length
	R> R> drop drop
;	

DEFER write-filepath_buffer ( map buf --)
\ map is a completed FITSKEY map that will interrogated to create the filename
\ buf points to IMAGE_DESCRIPTOR..FILEPATH_BUFFER 

: initialize-XISFfilepath ( img --)
\ prepare the filepath with filename for the XISF file
\ called by save-image
	>R
	R@ FITS_MAP @ ( map)
	R> FILEPATH_BUFFER
	256 over ( map buf 256 buf) declare-buffer
	( map buf) write-filepath_buffer
;

: create-imageDirectory ( img --)
\ if the image directory does not exist on disk, create it
	FILEPATH_BUFFER ( buf) >R
	R@ ( buf) buffer-drive-to-string	R> buffer-dir-to-string makeDirLevels abort" cannot create image directory"
;

: save-image { img | fileid -- }		\ VFX locals
\ save the image to an XISF file, the filename is created from the FITSmap
	img initialize-XISFimage
	img initialize-XISFfilepath
	img create-imageDirectory
	img FILEPATH_BUFFER buffer-to-string w/o 
		create-file abort" Cannot create XISF file" -> fileid
	img XISF_HEADER							( addr)
	img image_size XISF_HEADER_SIZE +	( addr file_size)
		fileid write-file abort" Cannot access XISF file"	
	fileid close-file abort" Cannot close XISF file"
;