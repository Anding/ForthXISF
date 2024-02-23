\ descriptor approach to managing images

  16 constant MAX_DESCRIPTORS
4096 constant XISF_HEADER_SIZE	

\ descriptor data structure for an image with properties
BEGIN-STRUCTURE IMAGE_DESCRIPTOR
	4 +FIELD LIST_NEXT									\ pointer to the next descriptor
	4 +FIELD META_MAP										\ pointer to the key-value metadata map
	4 +FIELD XISF_HEADER									\ pointer to the XISF_buffer
	4 +FIELD IMAGE_BITMAP								\ pointer to the image buffer
	4 +FIELD IMAGE_WIDTH									\ width in pixels
	4 +FIELD IMAGE_HEIGHT								\ height in pixels
	4 +FIELD IMAGE_DEPTH									\ depth in bitplanes
END-STRUCTURE

variable XISF.data	0 XISF.data !					\ see XISF.initialize
variable XISF.free										\ number of free descriptors

: initialize-descriptors ( N --)
\ create the list of free descriptors
\ XISF.data points to the first free descriptor, or = 0 if there is none
\ the LIST_NEXT field points to the next free descriptor or = 0 if there are none
	MAX_DESCRIPTORS dup XISF.free !				( N)			\ save the number of free descriptors
	dup IMAGE_DESCRIPTOR * allocate THROW 		( N addr)	\ allocate space for N descriptor structures
	dup XISF.data !									( N addr)	\ XISF.data points to the first free descriptor
	swap 1 DO											( list_next)
		dup XISF_IMAGE + dup							( list_next addr+ addr+)
		rot !												( addr+)
	LOOP
	drop
;

: new-descriptor ( -- img)
\ obtain and return the next free image descriptor
	XISF.data @ ?dup							( addr addr | 0)
	0= IF abort"  THROW THEN				( addr 0 | err.NoFreeStrings)
	dup @ XISF.data !							\ repoint $.data to the next free descriptor
	-1 XISF.free +!							\ update the number of free descriptors
;

: 

: XISF.make ( width height -- img)
\ allocate memory and establish a new image, as represented by a descriptor
	new-descriptor >R
	2dup * 2* ( single bitplane) allocate if abort" Unable to allocate memory" then ( width height addr R:img)
	R@ IMAGE_BITMAP !
	XISF_HEADER_SIZE allocate if abort" Unable to allocate memory" then ( width height addr R:img)
	R@ XISF_HEADER !
	\ map dup R@ swap META_MAP !
	R@ IMAGE_HEIGHT !
	R@ IMAGE_WIDTH !
	1 R@ IMAGE_DEPTH !
	R> drop
;
	
	