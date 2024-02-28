
\ descriptor data structure for an image
BEGIN-STRUCTURE
					IMAGE_DESCRIPTOR
					4 	+FIELD IMAGE_WIDTH				\ width in pixels
					4 	+FIELD IMAGE_HEIGHT				\ height in pixels
					4 	+FIELD IMAGE_DEPTH				\ depth in bitplanes
					4 	+FIELD META_MAP					\ pointer to the key-value metadata map	
XISF_HEADER_SIZE	+FIELD XISF_HEADER				\ pointer to the XISF_buffer
					0 	+FIELD IMAGE_BITMAP				\ pointer to the image buffer
END-STRUCTURE

: new-image  ( width height depth -- img)
\ allocate memory and establish a new image, as represented by a descriptor
	>R 2dup R> dup ( 3dup)
	* * 2* IMAGE_DESCRIPTOR + 
	allocate if abort" Unable to allocate memory" then
	>R					( w h d R: img)
	R@ IMAGE_DEPTH !
	R@ IMAGE_HEIGHT !
	R@ IMAGE_WIDTH !
	\ map R@ META_MAP !	
;




	