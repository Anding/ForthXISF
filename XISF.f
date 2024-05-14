\ Forth language tools for creating PixInsight XISF image format
\ requires buffers.f, ForthBase.f, FiniteFractions.f

4096 constant XISF_HEADER_SIZE

\ descriptor data structure for an image
BEGIN-STRUCTURE IMAGE_DESCRIPTOR
					4 	+FIELD IMAGE_WIDTH				\ width in pixels
					4 	+FIELD IMAGE_HEIGHT				\ height in pixels
					4 	+FIELD IMAGE_DEPTH				\ depth in bitplanes
					4 	+FIELD META_MAP					\ pointer to the key-value metadata map	
BUFFER_DESCRIPTOR +FIELD XISF_BUFFER				\ descriptor to the XISF header buffer
XISF_HEADER_SIZE	+FIELD XISF_HEADER				\ XISF header buffer immediately follows the descriptor
					0 	+FIELD IMAGE_BITMAP				\ pointer to the image buffer
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
	\ map R@ META_MAP !	
	R>
;

: free-image ( img --)
\ release the memory allocated to an image
	free drop
;

: image-to-file ( img fileid --)
\ write the image to fileid in XISF format
\ fileid is not closed
	>R >R
	R@ XISF_HEADER					( addr R:fileid img)
	R@ IMAGE_WIDTH @
	R@ IMAGE_HEIGHT @
	R@ IMAGE_DEPTH @
	2* * * XISF_HEADER_SIZE +	( addr size R:fileid img)
	R> drop
 	R>				  					( addr n fileid)
	write-file abort" cannot access file"	
;

: save-image ( img caddr n --)
\ save the image to an XISF file with the given (location and) name
	w/o create-file abort" Cannot create XISF file"
	>R
	R@ image-to-file
	R> close-file abort" Cannot close XISF file"
;