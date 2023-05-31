4080 constant XISFHeaderMaxLen			\ XISF_DATA will appear at 4096
3096 constant XISFMaxImageWidth
2080 constant XISFMaxImageHeight
XISFMaxImageWidth XISFMaxImageHeight 2 * * constant XISFDataMaxLen

BEGIN-STRUCTURE XISF_BUFFER
	8 +FIELD XISF_SIGNATURE
	4 +FIELD XISF_HEADER_LEN
	4 +FIELD XISF_RESERVED
	XISFHeaderMaxLen	+FIELD XISF_HEADER		\ header with trailing zeros
	XISFDataMaxLen		+FIELD XISF_DATA 			\ data with trailing zeros
END-STRUCTURE

XISF_BUFFER allocate ( addr ior) throw constant XISFBuffer  \ BUFFER: cannot handle allocations of this size

variable XISFBufferPointer
variable XISFHeaderPointer
	
: XISF.StartHeader ( XISFbuff -- )
	dup XISFBufferPointer !	
	XISF_Header XISFHeaderPointer !
;

: XISF.HeaderLength ( -- n )
	XISFHeaderPointer @ XISFBufferPointer @ XISF_Header -
;
	
: XISF.WriteToHeader ( addr n -- )
	dup >R
	XISFHeaderPointer @ swap cmove
	R> XISFHeaderPointer +!
;

: XISF.WriteIntToHeader ( x -- )
	<# dup SIGN 0 ( x-as-double) #S #> ( caddr u)
	XISF.WriteToHeader
;
	
: XISF.FinishHeader ( -- )
	 s" XISF0100" XISFBufferPointer @ swap ( caddr buffer u ) cmove
	 XISF.HeaderLength XISFBufferPointer @ XISF_HEADER_LEN ( len addr) l!
;

: XISF.StartXML ( -- )
	s\" <?xml version=\"1.0\" encoding=\"UTF-8\"?>"	XISF.WriteToHeader
	s\" <xisf version=\"1.0\">"		XISF.WriteToHeader
;

: XISF.FinishXML
	s\" </xisf>"							XISF.WriteToHeader
;

: XISF.StartImage
	s\" <Image geometry=\""				XISF.WriteToHeader
	3096										XISF.WriteIntToHeader	\ width
	s\" :"									XISF.WriteToHeader
	2080 	 									XISF.WriteIntToHeader	\ height
	s\" :1\" sampleFormat=\"UInt16\" colorSpace=\"Gray\" location=\"attachment:"	XISF.WriteToHeader
	0 XISF_DATA 							XISF.WriteIntToHeader	\ location
	s\" :"									XISF.WriteToHeader
	XISFDataMaxLen							XISF.WriteIntToHeader	\ size
	s\" \">"									XISF.WriteToHeader
;

: XISF.FinishImage
	s\" </Image>"							XISF.WriteToHeader
;

: XISF.MAKE-FITSKEY-INT ( caddr u addr <name> -- ) 
\ defining word for a FITS key with integer value
\ e.g. variable-name S" FITS-keyword" XISF.MAKE-FITSKEY-INT <name>
	CREATE 
		, $,
	DOES> ( --)
		dup >R @	@							( value)
		R> cell+ count						( value caddr u)
		s\" <FITSKeyword name=\""		XISF.WriteToHeader
		( value caddr u) 					XISF.WriteToHeader
		s\" \" value=\""					XISF.WriteToHeader
		( value) 							XISF.WriteIntToHeader
		s\" \" />"							XISF.WriteToHeader
;

: XISF.WriteFile ( caddr n --)
	w/o create-file if abort" Cannot create XISF file" then
	>R XISFBufferPointer @ XISF_BUFFER R@	( caddr u fid)
	write-file if abort" Cannot write XISF file" then
	R> close-file if abort" Cannot close XISF file" then
;





