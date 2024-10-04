\ Forth language tools for creating PixInsight XISF image format
\ requires buffers.f, ForthBase.f, FiniteFractions.f
\ https://pixinsight.com/doc/docs/XISF-1.0-spec/XISF-1.0-spec.html

4096 constant XISF_HEADER_SIZE

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
			':' ~~~$	( finite fractions utility) R@ xml.keyval
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

: image-to-file ( img fileid --)
\ write the image to fileid in XISF format
\ fileid is not closed
	>R >R
	R@ initialize-XISFimage
	R@ XISF_HEADER							( addr R:fileid img)
	R@ image_size XISF_HEADER_SIZE +	( addr file_size R:fileid img)
	R> drop
 	R>				  							( addr n fileid)
	write-file abort" cannot access file"	
;

: save-image ( img caddr n --)
\ save the image to an XISF file with the given (location and) name
	w/o create-file abort" Cannot create XISF file"
	>R
	R@ image-to-file
	R> close-file abort" Cannot close XISF file"
;