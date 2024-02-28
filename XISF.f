\ Forth language tools for creating PixInsight XISF image format
\ requires ForthBase.f, FiniteFractions.f

4096 constant XISF_HEADER_SIZE

\ descriptor data structure for an image
BEGIN-STRUCTURE
					IMAGE_DESCRIPTOR
					4 	+FIELD IMAGE_WIDTH				\ width in pixels
					4 	+FIELD IMAGE_HEIGHT				\ height in pixels
					4 	+FIELD IMAGE_DEPTH				\ depth in bitplanes
					4 	+FIELD META_MAP					\ pointer to the key-value metadata map	
BUFFER_DESCRIPTOR +FIELD XISF_BUFFER				\ descriptior to the XISF header buffer
XISF_HEADER_SIZE	+FIELD XISF_HEADER				\ XISF header buffer
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

\ XISF monolithic file structure, from the XISF specification
BEGIN-STRUCTURE 
					XISF_BUFFER
	8 +FIELD 	XISF_SIGNATURE
	4 +FIELD 	XISF_HEADER_LEN
	4 +FIELD 	XISF_RESERVED
	XISF_HEADER_SIZE 0 XISF_SIGNATURE XISF_HEADER_LEN XISF_RESERVED -
	  +FIELD 	XISF_HEADER		\ header with trailing zeros
	0 +FIELD 	XISF_DATA 		\ image bitmap with trailing zeros
END-STRUCTURE

variable XISFBufferPointer		\ address of the start of the presently active buffer
variable XISFHeaderPointer		\ address of the current 'cursor location' in the presently active buffer
variable XISFBufferSize			\ size of the presently active buffer
	
: XISF.HeaderLength ( -- n )
\ compute the length in bytes of header as currently written
	XISFHeaderPointer @ XISFBufferPointer @ XISF_Header -
;

: XISF.StartHeader ( XISFbuff -- )
\ call this once to initialize the header
	dup XISFBufferPointer !	
	XISF_Header dup XISFHeaderPointer !
	XISFHeaderMaxLen 0 ( addr n 0) fill		\ zero the header
;

: XISF.WriteToHeader ( addr n -- )
\ write a string to the buffer at the current cursor location
	dup >R
	XISFHeaderPointer @ swap cmove
	R> XISFHeaderPointer +!
;

: XISF.WriteIntToHeader ( addr n --)
\ convert an integer to a string and write it to the header at the current cursor location
	<# dup SIGN 0 ( x-as-double) #S #> ( caddr u)
	XISF.WriteToHeader
;

: FITS.str ( addr -)
\ fetch a counted sting at addr and write it to the header
	$@ 
	XISF.WriteToHeader
;

: FITS.int ( addr -)
\ fetch an integer at addr, convert it to a string and it write to the header at the current cursor location
	@
	XISF.WriteIntToHeader
;

: FITS.ff: ( f --)
\ fetch a finite fraction  at addr, convert it to a : separated string and write it to the header
	@ ':' ~$ ( caddr u)
	XISF.WriteToHeader
;

: FITS.ff- ( f --)
\ fetch a finite fraction  at addr, convert it to a : separated string and write it to the header
	@ '-' ~$ ( caddr u)
	XISF.WriteToHeader
;

: XISF.StartXML ( -- )
\ call this after XISF.StartHeader
	s\" <?xml version=\"1.0\" encoding=\"UTF-8\"?>"	XISF.WriteToHeader
	s\" <xisf version=\"1.0\">"		XISF.WriteToHeader
;

: XISF.StartImage
\ call this after XISF.StartXML
	s\" <Image geometry=\""				XISF.WriteToHeader
	ImageWidth @ dup						XISF.WriteIntToHeader	\ width
	s\" :"									XISF.WriteToHeader
	ImageHeight @ dup						XISF.WriteIntToHeader	\ height
	s\" :1\" sampleFormat=\"UInt16\" colorSpace=\"Gray\" location=\"attachment:"	XISF.WriteToHeader
	0 XISF_DATA ( ... offset)			XISF.WriteIntToHeader	\ location
	s\" :"									XISF.WriteToHeader
	( width height) 2 * * dup 			XISF.WriteIntToHeader	\ size in bytes of the image buffer
	s\" \">"									XISF.WriteToHeader
	( dataSize) 0 XISF_DATA + XISFBufferSize !					\ update the buffer size to match the image size
;

: XISF.FinishImage
\ call this after XISF.StartImage and any optional FITS keywords
	s\" </Image>"							XISF.WriteToHeader
;

: XISF.FinishXML
\ call this after XISF.FinishImage
	s\" </xisf>"							XISF.WriteToHeader
;

: XISF.FinishHeader ( -- )
\ call this after XISF.FinishXML
\ completes the header according to XISF specification
	 s" XISF0100" XISFBufferPointer @ swap ( caddr buffer u ) cmove
	 XISF.HeaderLength XISFBufferPointer @ XISF_HEADER_LEN ( len addr) l!
;

: FITS.MAKE ( caddr u variable XT <name> -- ) 
\ defining word for a FITS key
\ e.g. s" FOCUSPOS" focusPos ' FITS.INT FITS.MAKE FITS.KEYfocusPos
	CREATE 
		, , $, 								( PFA: XT, variable, counted-string)
	DOES> ( --)
		>R										( R:PFA)
		R@ 2 cells+ $@						( caddr u R:PFA)
		s\" <FITSKeyword name=\""		XISF.WriteToHeader
		( caddr u) 							XISF.WriteToHeader
		s\" \" value=\""					XISF.WriteToHeader
		R@ cell+ @							( variable R:PFA)
		R>	@									( variable XT)
		execute		
		s\" \" />"							XISF.WriteToHeader
;

: XISF.WriteFile ( caddr n --)
\ write the XISF buffer to an XISF file with the given (location and) name
	w/o create-file if abort" Cannot create XISF file" then
	>R XISFBufferPointer @ XISFBufferSize @ R@					( caddr u fid)
	write-file if abort" Cannot write XISF file" then
	R> close-file if abort" Cannot close XISF file" then
;





